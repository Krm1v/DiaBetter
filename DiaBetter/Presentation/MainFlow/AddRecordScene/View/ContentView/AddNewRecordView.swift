//
//  AddNewRecordView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.04.2023.
//

import UIKit
import Combine

enum AddNewRecordActions {
	case hideKeyboardDidTapped
	case saveButtonTapped
	case closeButtonTapped
	case noteTextViewDidChanged(String)
	case fastInsulinTextfieldDidChanged(String)
	case basalInsulinTextfieldDidChanged(String)
	case glucoseOrMealTextfieldDidChanged(String, GlucoseLevelOrMealCellModel?)
	case dateDidChanged(Date)
}

final class AddNewRecordView: BaseView {
	// MARK: - Typealiases
	private typealias Datasource = UICollectionViewDiffableDataSource<RecordParameterSections, RecordParameterItems>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<RecordParameterSections, RecordParameterItems>

	// MARK: - Properties
	private var datasource: Datasource?
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<AddNewRecordActions, Never>()

	// MARK: - UI Elements
	private lazy var collectionView = UICollectionView(frame: self.bounds,
													   collectionViewLayout: makeLayout())
	private lazy var hideKeyboardTap = UITapGestureRecognizer()

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupCollectionView()
		setupBindings()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupCollectionView()
		setupBindings()
	}

	// MARK: - Public methods
	func setupSnapshot(sections: [SectionModel<RecordParameterSections, RecordParameterItems>]) {
		var snapshot = Snapshot()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		datasource?.apply(snapshot)
	}

	func changeScrollViewInsets(insets: UIEdgeInsets) {
		collectionView.contentInset = insets
		collectionView.scrollIndicatorInsets = insets
	}
}

// MARK: - Private extension
private extension AddNewRecordView {
	// MARK: - SetupUI
	func setupUI() {
		backgroundColor = .black
		setupLayout()
		addGestureRecognizer(hideKeyboardTap)
		collectionView.delaysContentTouches = false
	}

	func setupLayout() {
		addSubview(collectionView, constraints: [
			collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
		])
	}

	func setupCollectionView() {
		collectionView.backgroundColor = .black
		collectionView.register(
			DatePickerCell.self,
			forCellWithReuseIdentifier: DatePickerCell.reuseID)

		collectionView.register(
			GlucoseLevelOrMealCell.self,
			forCellWithReuseIdentifier: GlucoseLevelOrMealCell.reuseID)

		collectionView.register(
			InsulinCell.self,
			forCellWithReuseIdentifier: InsulinCell.reuseID)

		collectionView.register(
			NoteCell.self,
			forCellWithReuseIdentifier: NoteCell.reuseID)

		collectionView.register(
			ButtonsCell.self,
			forCellWithReuseIdentifier: ButtonsCell.reuseID)

		setupDatasource()
	}

	// MARK: - DiffableDatasource setup
	func setupDatasource() {
		datasource = UICollectionViewDiffableDataSource<RecordParameterSections, RecordParameterItems>(
			collectionView: collectionView,
			cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
			guard let self = self else {
				return UICollectionViewCell()
			}
			switch item {
			case .date(let model):
				let cell = collectionView.configureCell(
					cellType: DatePickerCell.self,
					indexPath: indexPath)

				cell.configure(model: model)
				cell.actionPublisher
					.sink { [unowned self] action in
						switch action {
						case .dateDidChanged(let date):
							self.actionSubject.send(.dateDidChanged(date))
						}
					}
					.store(in: &cancellables)
				return cell

			case .glucoseLevelOrMeal(let model):
				let cell = collectionView.configureCell(
					cellType: GlucoseLevelOrMealCell.self,
					indexPath: indexPath)

				cell.configure(with: model)
				let object = getObject(with: indexPath)
				cell.actionPublisher
					.sink { [unowned self] action in
						switch action {
						case .textFieldValueDidChanged(let text):
							self.actionSubject.send(.glucoseOrMealTextfieldDidChanged(text, object))
						}
					}
					.store(in: &cancellables)
				return cell

			case .insulin(let model):
				let cell = collectionView.configureCell(
					cellType: InsulinCell.self,
					indexPath: indexPath)

				cell.actionPublisher
					.sink { [unowned self] action in
						switch action {
						case .fastInsulinTextfieldDidChanged(let text):
							self.actionSubject.send(.fastInsulinTextfieldDidChanged(text))
						case .basalInsulinTextfieldDidChanged(let text):
							self.actionSubject.send(.basalInsulinTextfieldDidChanged(text))
						}
					}
					.store(in: &cancellables)
				cell.configure(with: model)
				return cell

			case .note(let model):
				let cell = collectionView.configureCell(
					cellType: NoteCell.self,
					indexPath: indexPath)

				cell.configure(with: model)
				cell.actionPublisher
					.sink { [unowned self] action in
						switch action {
						case .textViewDidChanged(let text):
							self.actionSubject.send(.noteTextViewDidChanged(text))
						}
					}
					.store(in: &cancellables)
				return cell

			case .buttons:
				let cell = collectionView.configureCell(
					cellType: ButtonsCell.self,
					indexPath: indexPath)

				cell.actionPublisher
					.sink { [unowned self] action in
						switch action {
						case .saveButtonDidTapped:
							self.actionSubject.send(.saveButtonTapped)
						case .closeButtonDidTapped:
							self.actionSubject.send(.closeButtonTapped)
						}
					}
					.store(in: &cancellables)
				return cell
			}
		})
	}

	func getObject(with indexPath: IndexPath) -> GlucoseLevelOrMealCellModel? {
		guard let object = datasource?.itemIdentifier(for: indexPath) else {
			return nil
		}
		var modelToReturn: GlucoseLevelOrMealCellModel?
		switch object {
		case .glucoseLevelOrMeal(let model):
			modelToReturn = model
		default: break
		}
		return modelToReturn
	}

	// MARK: - Compositional layout setup methods
	func makeLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
			guard let self = self else {
				return nil
			}
			guard let sections = RecordParameterSections(rawValue: sectionIndex) else {
				return nil
			}
			switch sections {
			case .date:
				return makeSection(groupSizeHeight: .fractionalWidth(Constants.dateSectionHeight))
			case .main:
				return makeSection(groupSizeHeight: .fractionalWidth(Constants.mainSectionHeight))
			case .insulin:
				return makeSection(groupSizeHeight: .fractionalWidth(Constants.insulinSectionHeight))
			case .note:
				return makeSection(groupSizeHeight: .fractionalWidth(Constants.noteSectionHeight))
			case .buttons:
				return makeSection(groupSizeHeight: .fractionalWidth(Constants.buttonsSectionHeight))
			}
		}
		return layout
	}

	func makeSection(groupSizeHeight: NSCollectionLayoutDimension) -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(Constants.defaultItemSize),
			heightDimension: .fractionalHeight(Constants.defaultItemSize))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		item.contentInsets = NSDirectionalEdgeInsets(
			top: Constants.defaultEdgeInset,
			leading: Constants.defaultEdgeInset,
			bottom: .zero,
			trailing: Constants.defaultEdgeInset)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(Constants.defaultItemSize),
			heightDimension: groupSizeHeight)

		let group = NSCollectionLayoutGroup.vertical(
			layoutSize: groupSize,
			subitem: item,
			count: 1)

		let section = NSCollectionLayoutSection(group: group)
		return section
	}

	// MARK: - Action bindings
	func setupBindings() {
		hideKeyboardTap.tapPublisher
			.map { _ in AddNewRecordActions.hideKeyboardDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}

// MARK: - Constants
private enum Constants {
	static let dateSectionHeight: 	 CGFloat = 0.16
	static let mainSectionHeight: 	 CGFloat = 0.15
	static let insulinSectionHeight: CGFloat = 0.27
	static let noteSectionHeight: 	 CGFloat = 0.5
	static let buttonsSectionHeight: CGFloat = 0.32
	static let defaultItemSize: 	 CGFloat = 1.0
	static let defaultEdgeInset: 	 CGFloat = 16
}

#if DEBUG
// MARK: - SwiftUI preview
import SwiftUI

struct FlowProvider: PreviewProvider {
	static var previews: some View {
		UIViewControllerPreview {
			let container = AppContainerImpl()
			let vm = AddRecordSceneViewModel(
				recordsService: container.recordsService,
				userService: container.userService)
			let viewController = AddRecordSceneViewController(viewModel: vm)
			return viewController
		}
	}
}
#endif
