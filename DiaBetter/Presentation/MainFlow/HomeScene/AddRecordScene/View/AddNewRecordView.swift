//
//  AddNewRecordView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.04.2023.
//

import UIKit
import Combine

enum AddNewRecordActions {
	case saveButtonTapped
	case closeButtonTapped
}

final class AddNewRecordView: BaseView {
	//MARK: - Typealiases
	typealias Datasource = UICollectionViewDiffableDataSource<RecordParameterSections, RecordParameterItems>
	typealias Snapshot = NSDiffableDataSourceSnapshot<RecordParameterSections, RecordParameterItems>
	
	//MARK: - Properties
	private var datasource: Datasource?
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<AddNewRecordActions, Never>()
	
	//MARK: - UI Elements
	private lazy var collectionView = UICollectionView(frame: self.bounds,
													   collectionViewLayout: makeLayout())
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupCollectionView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupCollectionView()
	}
	
	//MARK: - Public methods
	func setupSnapshot(sections: [SectionModel<RecordParameterSections, RecordParameterItems>]) {
		var snapshot = Snapshot()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		datasource?.apply(snapshot)
	}
}

//MARK: - Private extension
private extension AddNewRecordView {
	//MARK: - SetupUI
	func setupUI() {
		backgroundColor = .black
		setupLayout()
		addTapGesture()
		collectionView.delaysContentTouches = false
	}
	
	func setupLayout() {
		addSubview(collectionView, constraints: [
			collectionView.topAnchor.constraint(equalTo: topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
		])
	}
	
	func setupCollectionView() {
		collectionView.backgroundColor = .black
		collectionView.register(DatePickerCell.self, forCellWithReuseIdentifier: DatePickerCell.reuseID)
		collectionView.register(GlucoseLevelOrMealCell.self, forCellWithReuseIdentifier: GlucoseLevelOrMealCell.reuseID)
		collectionView.register(InsulinCell.self, forCellWithReuseIdentifier: InsulinCell.reuseID)
		collectionView.register(NoteCell.self, forCellWithReuseIdentifier: NoteCell.reuseID)
		collectionView.register(ButtonsCell.self, forCellWithReuseIdentifier: ButtonsCell.reuseID)
		setupDatasource()
	}
	
	//MARK: - DiffableDatasource setup
	func setupDatasource() {
		datasource = UICollectionViewDiffableDataSource<RecordParameterSections, RecordParameterItems>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
			guard let self = self else { return UICollectionViewCell() }
			switch item {
			case .date(let model):
				let cell = collectionView.configureCell(cellType: DatePickerCell.self,
														indexPath: indexPath)
				cell.configure(model: model)
				return cell
			case .glucoseLevelOrMeal(let model):
				let cell = collectionView.configureCell(cellType: GlucoseLevelOrMealCell.self,
														indexPath: indexPath)
				cell.configure(with: model)
				return cell
			case .insulin(let model):
				let cell = collectionView.configureCell(cellType: InsulinCell.self,
														indexPath: indexPath)
				cell.configure(with: model)
				return cell
			case .note(let model):
				let cell = collectionView.configureCell(cellType: NoteCell.self,
														indexPath: indexPath)
				cell.configure(with: model)
				return cell
			case .buttons:
				let cell = collectionView.configureCell(cellType: ButtonsCell.self,
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
	
	//MARK: - Compositional layout setup methods
	func makeLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else {
				return nil
			}
			guard let sections = RecordParameterSections(rawValue: sectionIndex) else {
				return nil
			}
			switch sections {
			case .date:
				return makeDateSection()
			case .main:
				return makeMainSection()
			case .unsulin:
				return makeInsulinSection()
			case .note:
				return makeNoteSection()
			case .buttons:
				return makeButtonsSection()
			}
		}
		return layout
	}
	
	func makeDateSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 16,
													 leading: 16,
													 bottom: .zero,
													 trailing: 16)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: .fractionalHeight(0.08))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
													 subitem: item,
													 count: 1)
		let section = NSCollectionLayoutSection(group: group)
		return section
	}
	
	func makeMainSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 16,
													 leading: 16,
													 bottom: .zero,
													 trailing: 16)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: .fractionalHeight(0.15))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
													 subitem: item,
													 count: 1)
		let section = NSCollectionLayoutSection(group: group)
		return section
	}
	
	func makeInsulinSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 16,
													 leading: 16,
													 bottom: .zero,
													 trailing: 16)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: .fractionalHeight(0.2))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
													 subitem: item,
													 count: 1)
		let section = NSCollectionLayoutSection(group: group)
		return section
	}
	
	func makeNoteSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 16,
													 leading: 16,
													 bottom: .zero,
													 trailing: 16)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: .fractionalHeight(0.25))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
													 subitem: item,
													 count: 1)
		let section = NSCollectionLayoutSection(group: group)
		return section
	}
	
	func makeButtonsSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 16,
													 leading: 16,
													 bottom: .zero,
													 trailing: 16)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: .estimated(135))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
													 subitem: item,
													 count: 1)
		let section = NSCollectionLayoutSection(group: group)
		return section
	}
	
	//MARK: - Other helpers
	func addTapGesture() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		addGestureRecognizer(tap)
	}
	
	@objc
	func hideKeyboard() {
		endEditing(true)
	}
}

#if DEBUG
//MARK: - SwiftUI preview
import SwiftUI

struct FlowProvider: PreviewProvider {
	static var previews: some View {
		UIViewControllerPreview {
			let container = AppContainerImpl()
			let vm = AddRecordSceneViewModel(recordsService: container.recordsService)
			let viewController = AddRecordSceneViewController(viewModel: vm)
			return viewController
		}
	}
}
#endif
