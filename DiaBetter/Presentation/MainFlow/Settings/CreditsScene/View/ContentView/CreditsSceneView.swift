//
//  CreditsSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.06.2023.
//

import UIKit
import Combine

enum CreditsSceneActions {
	case cellDidTapped(CreditsListCellModel)
}

final class CreditsSceneView: BaseView {
	typealias CreditsSceneDatasource = UICollectionViewDiffableDataSource<CreditsSceneSections, CreditsSceneItems>
	typealias CreditsSceneSnapshot = NSDiffableDataSourceSnapshot<CreditsSceneSections, CreditsSceneItems>

	// MARK: - UI Elements
	private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())

	// MARK: - Properties
	private var datasource: CreditsSceneDatasource?
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<CreditsSceneActions, Never>()

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupBindings()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupBindings()
	}

	// MARK: - Public methods
	func setupSnapshot(sections: [SectionModel<CreditsSceneSections, CreditsSceneItems>]) {
		var snapshot = CreditsSceneSnapshot()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		datasource?.apply(snapshot)
	}
}

// MARK: - Private extension
private extension CreditsSceneView {
	func setupUI() {
		setupLayout()
		setupCollectionView()
	}

	func setupLayout() {
		addSubview(collectionView, withEdgeInsets: .all(.zero))
	}

	func setupCollectionView() {
		collectionView.register(
			AppInfoCell.self,
			forCellWithReuseIdentifier: AppInfoCell.reuseID)

		collectionView.register(
			CreditsListCell.self,
			forCellWithReuseIdentifier: CreditsListCell.reuseID)

		setupDatasource()
	}

	func setupDatasource() {
		datasource = UICollectionViewDiffableDataSource(
			collectionView: collectionView,
			cellProvider: { collectionView, indexPath, item -> UICollectionViewCell? in
				switch item {
				case .appInfoItem(let model):
					let cell = collectionView.configureCell(
						cellType: AppInfoCell.self,
						indexPath: indexPath)

					cell.configure(model)
					return cell

				case .listItem(let model):
					let cell = collectionView.configureCell(
						cellType: CreditsListCell.self,
						indexPath: indexPath)

					cell.configure(model)
					return cell
				}
			})
	}

	// MARK: - Layout
	func makeLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else {
				return nil
			}
			guard let sections = CreditsSceneSections(rawValue: sectionIndex) else {
				return nil
			}
			switch sections {
			case .appInfoSection:
				return self.makeHeaderSection()
			case .socialMediaSection:
				return self.makeListSection(with: layoutEnvironment)
			case .termsAndConditionsSection:
				return self.makeListSection(with: layoutEnvironment)
			}
		}
		let configuration = UICollectionViewCompositionalLayoutConfiguration()
		configuration.interSectionSpacing = 8
		layout.configuration = configuration
		return layout
	}

	func makeHeaderSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalHeight(1.0))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		item.contentInsets = NSDirectionalEdgeInsets(
			top: .zero,
			leading: Constants.defaultEdgeInset,
			bottom: .zero,
			trailing: Constants.defaultEdgeInset)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalWidth(0.5))

		let group = NSCollectionLayoutGroup.vertical(
			layoutSize: groupSize,
			subitem: item,
			count: 1)

		let section = NSCollectionLayoutSection(group: group)
		return section
	}

	func makeListSection(with layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
		configuration.backgroundColor = .black

		let section = NSCollectionLayoutSection.list(
			using: configuration,
			layoutEnvironment: layoutEnvironment)

		section.contentInsets = NSDirectionalEdgeInsets(
			top: Constants.defaultEdgeInset,
			leading: Constants.defaultEdgeInset,
			bottom: .zero,
			trailing: Constants.defaultEdgeInset)

		return section
	}

	func getObject(with indexPath: IndexPath) -> CreditsListCellModel? {
		guard let object = datasource?.itemIdentifier(for: indexPath) else {
			return nil
		}

		var model: CreditsListCellModel?
		switch object {
		case .listItem(let listModel):
			model = listModel
		default: break
		}
		return model
	}

	func setupBindings() {
		collectionView.didSelectItemPublisher
			.sink { [unowned self] indexPath in
				guard let object = getObject(with: indexPath) else {
					return
				}
				actionSubject.send(.cellDidTapped(object))
			}
			.store(in: &cancellables)
	}
}

// MARK: - Constants
private enum Constants {
	static let defaultEdgeInset: CGFloat = 16
}
