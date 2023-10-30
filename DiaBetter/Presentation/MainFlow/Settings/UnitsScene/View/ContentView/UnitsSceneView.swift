//
//  UnitsSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.06.2023.
//

import UIKit
import Combine
import CombineCocoa

enum UnitsSceneActions {
	case glucoseUnitsDidChanged(SettingsUnits.GlucoseUnitsState)
	case carbsMenuDidTapped(SettingsUnits.CarbsUnits)
	case saveButtonDidTapped
	case targetGlucoseValueDidChaged(Double, MinMaxGlucoseTarget)
}

final class UnitsSceneView: BaseView {
	typealias UnitsSceneDatasource = UICollectionViewDiffableDataSource<UnitsSceneSections, UnitsSceneItems>
	typealias UnitsSceneSnapshot = NSDiffableDataSourceSnapshot<UnitsSceneSections, UnitsSceneItems>

	// MARK: - UI Elements
	private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
	private lazy var saveButton = buildNavBarButton()

	// MARK: - Properties
	private var datasource: UnitsSceneDatasource?
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<UnitsSceneActions, Never>()

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		bindActions()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		bindActions()
	}

	// MARK: - Public methods
	func setupSnapshot(sections: [SectionModel<UnitsSceneSections, UnitsSceneItems>]) {
		var snapshot = UnitsSceneSnapshot()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		datasource?.apply(snapshot, animatingDifferences: false)
	}

	func setupSaveButton(for controller: UIViewController) {
		saveButton.style = .plain
		saveButton.title = Localization.save
		controller.navigationItem.rightBarButtonItem = saveButton
	}
}

// MARK: - Private extension
private extension UnitsSceneView {
	func setupUI() {
		setupLayout()
		setupCollectionView()
	}

	func setupLayout() {
		addSubview(collectionView, withEdgeInsets: .all(.zero))
	}

	func setupCollectionView() {
		collectionView.register(
			GlucoseUnitsCell.self,
			forCellWithReuseIdentifier: GlucoseUnitsCell.reuseID)

		collectionView.register(
			CarbsUnitsCell.self,
			forCellWithReuseIdentifier: CarbsUnitsCell.reuseID)

		collectionView.register(
			TargetGlucoseCell.self,
			forCellWithReuseIdentifier: TargetGlucoseCell.reuseID)

		collectionView.register(
			UnitsSectionHeader.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: UnitsSectionHeader.reuseId)

		setupDatasource()
	}

	// MARK: - Datasource setup
	func setupDatasource() {
		datasource = UICollectionViewDiffableDataSource(
			collectionView: collectionView,
			cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
			guard let self = self else {
				return UICollectionViewCell()
			}

			switch item {
			case .plainWithSegmentedControl(let model):
				let cell = collectionView.configureCell(
					cellType: GlucoseUnitsCell.self,
					indexPath: indexPath)

				cell.configure(model)
				cell.actionPublisher
					.sink { [unowned self] actions in
						switch actions {
						case .segmentedControlValueDidChanged(let state):
							self.actionSubject.send(.glucoseUnitsDidChanged(state))
						}
					}
                    .store(in: &cell.cancellables)
				return cell

			case .plainWithUIMenu(let model):
				let cell = collectionView.configureCell(
					cellType: CarbsUnitsCell.self,
					indexPath: indexPath)

				cell.configure(model)
				cell.actionPublisher
					.sink { [unowned self] action in
						switch action {
						case .menuDidTapped(let carbsItem):
							self.actionSubject.send(.carbsMenuDidTapped(carbsItem))
						}
					}
					.store(in: &cancellables)
				return cell

			case .plainWithStepper(let model):
				let cell = collectionView.configureCell(
					cellType: TargetGlucoseCell.self,
					indexPath: indexPath)
                
				cell.configure(model)
				cell.actionPublisher
					.sink { [unowned self] action in
						switch action {
						case .stepperDidTapped(let value):
                            guard let object = self.getObject(with: indexPath) else {
                                return
                            }
							self.actionSubject.send(.targetGlucoseValueDidChaged(value, object))
                            debugPrint("Value: \(value), Object: \(object)")
						}
					}
                    .store(in: &cell.cancellables)
				return cell
			}
		})
		datasource?.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
			guard kind == UICollectionView.elementKindSectionHeader else {
				return nil
			}
			let sectionHeader = collectionView.dequeueReusableSupplementaryView(
				ofKind: kind,
				withReuseIdentifier: UnitsSectionHeader.reuseId,
				for: indexPath) as? UnitsSectionHeader

			let section = self?.datasource?.snapshot().sectionIdentifiers[indexPath.section]
			if section?.title == nil {
				return nil
			}
			sectionHeader?.titleLabel.text = section?.title

			return sectionHeader
		}
	}

	// MARK: - Layout
	func makeLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
			guard let self = self else {
				return nil
			}
			guard let sections = UnitsSceneSections(rawValue: sectionIndex) else {
				return nil
			}
			switch sections {
			case .main: 		 return makeMainListSection(with: layoutEnvironment)
			case .glucoseTarget: return makeListSection(with: layoutEnvironment)
			}
		}
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.interSectionSpacing = 16
		layout.configuration = configuration
		return layout
	}

	func makeMainListSection(
		with layoutEnvironment: NSCollectionLayoutEnvironment
	) -> NSCollectionLayoutSection {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		configuration.showsSeparators = false
		configuration.backgroundColor = .black
		let section = NSCollectionLayoutSection.list(
			using: configuration,
			layoutEnvironment: layoutEnvironment)

		section.contentInsets = NSDirectionalEdgeInsets(
			top: 16,
			leading: 16,
			bottom: .zero,
			trailing: 16)

		return section
	}

	func makeListSection(
		with layoutEnvironment: NSCollectionLayoutEnvironment
	) -> NSCollectionLayoutSection {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		configuration.backgroundColor = .black
		let section = NSCollectionLayoutSection.list(
			using: configuration,
			layoutEnvironment: layoutEnvironment)

		section.contentInsets = NSDirectionalEdgeInsets(
			top: 16,
			leading: 16,
			bottom: .zero,
			trailing: 16)

		let header = makeSectionHeader()
		section.boundarySupplementaryItems = [header]
		return section
	}

	func makeSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
		let headerSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalWidth(0.05))

		let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: headerSize,
			elementKind: UICollectionView.elementKindSectionHeader,
			alignment: .topLeading,
			absoluteOffset: CGPoint(x: .zero, y: 10))

		return sectionHeader
	}

	func bindActions() {
		saveButton.tapPublisher
			.map { UnitsSceneActions.saveButtonDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}

	func getObject(with indexPath: IndexPath) -> MinMaxGlucoseTarget? {
		guard let object = datasource?.itemIdentifier(for: indexPath) else {
			return nil
		}
		switch object {
		case .plainWithStepper(let model):
			switch model.type {
            case .min: return .min
			case .max: return .max
			}
		default: break
		}
		return nil
	}
}
