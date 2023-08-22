//
//  DataSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.07.2023.
//

import UIKit
import Combine

enum DataSceneActions {
	case backupDidTapped(BackupCellModel)
}

final class DataSceneView: BaseView {
	typealias DataSceneDatasource = UICollectionViewDiffableDataSource<DataSceneSections, DataSceneItems>
	typealias DataSceneSnapshot = NSDiffableDataSourceSnapshot<DataSceneSections, DataSceneItems>

	// MARK: - UI Elements
	private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())

	// MARK: - Properties
	private var datasource: DataSceneDatasource?
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<DataSceneActions, Never>()

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
	func setupSnapshot(sections: [SectionModel<DataSceneSections, DataSceneItems>]) {
		var snapshot = DataSceneSnapshot()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		datasource?.apply(snapshot)
	}
}

// MARK: - Private extension
private extension DataSceneView {
	func setupUI() {
		setupColletionView()
		setupLayout()
	}

	func setupLayout() {
		addSubview(collectionView, withEdgeInsets: .all(.zero))
	}

	func setupColletionView() {
		collectionView.register(
			AppleHealthActivationCell.self,
			forCellWithReuseIdentifier: AppleHealthActivationCell.reuseID)

		collectionView.register(
			BackupCell.self,
			forCellWithReuseIdentifier: BackupCell.reuseID)

		collectionView.register(
			AppleHealthSectionFooter.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
			withReuseIdentifier: AppleHealthSectionFooter.reuseId)

		setupDatasource()
	}

	func setupDatasource() {
		datasource = .init(
			collectionView: collectionView,
			cellProvider: { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
				guard let self = self else {
					return UICollectionViewCell()
				}
				switch item {
				case .appleHealthItem(let model):
					let cell = collectionView.configureCell(
						cellType: AppleHealthActivationCell.self,
						indexPath: indexPath)

					cell.configure(model)
					return cell
				case .backupItem(let model):
					let cell = collectionView.configureCell(
						cellType: BackupCell.self,
						indexPath: indexPath)

					cell.configure(model)
					return cell
				case .importItem(let model):
					let cell = collectionView.configureCell(
						cellType: BackupCell.self,
						indexPath: indexPath)

					cell.configure(model)
					return cell
				}
			})

		datasource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
			guard kind == UICollectionView.elementKindSectionFooter else {
				return nil
			}
			let sectionFooter = collectionView.dequeueReusableSupplementaryView(
				ofKind: kind,
				withReuseIdentifier: AppleHealthSectionFooter.reuseId,
				for: indexPath) as? AppleHealthSectionFooter

			let section = self?.datasource?.snapshot().sectionIdentifiers[indexPath.section]
			sectionFooter?.titleLabel.text = section?.title

			return sectionFooter
		}
	}

	// MARK: - Layout
	func makeLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
			guard let self = self else {
				return nil
			}
			guard let sections = DataSceneSections(rawValue: sectionIndex) else {
				return nil
			}
			switch sections {
			case .appleHealth: 	 return makeListSection(with: layoutEnvironment, isFooterExist: true)
			case .backup: 	   	 return makeListSection(with: layoutEnvironment, isFooterExist: false)
			case .importSection: return makeListSection(with: layoutEnvironment, isFooterExist: false)
			}
		}
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.interSectionSpacing = 8
		layout.configuration = configuration
		return layout
	}

	func makeListSection(
		with layoutEnvironment: NSCollectionLayoutEnvironment,
		isFooterExist: Bool
	) -> NSCollectionLayoutSection {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		configuration.backgroundColor = .black
		configuration.showsSeparators = false
		let section = NSCollectionLayoutSection.list(
			using: configuration,
			layoutEnvironment: layoutEnvironment)

		section.contentInsets = NSDirectionalEdgeInsets(
			top: 16,
			leading: 16,
			bottom: .zero,
			trailing: 16)

		if isFooterExist {
			let footer = makeSectionFooter()
			section.boundarySupplementaryItems = [footer]
		}
		return section
	}

	func makeSectionFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
		let footerSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalWidth(0.05))

		let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: footerSize,
			elementKind: UICollectionView.elementKindSectionFooter,
			alignment: .bottom,
			absoluteOffset: CGPoint(x: .zero, y: 10))

		return sectionFooter
	}

	func bindActions() {
		collectionView.didSelectItemPublisher
			.sink { [unowned self] indexPath in
				guard let object = getObject(indexPath) else {
					return
				}
				actionSubject.send(.backupDidTapped(object))
			}
			.store(in: &cancellables)
	}

	func getObject(_ indexPath: IndexPath) -> BackupCellModel? {
		guard let object = datasource?.itemIdentifier(for: indexPath) else {
			return nil
		}

		var backupCellModel: BackupCellModel?
		switch object {
		case .backupItem(let model):
			backupCellModel = model
			
		case .importItem(let model):
			backupCellModel = model

		default: break
		}
		return backupCellModel
	}
}
