//
//  MeasurementsSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.02.2023.
//

import UIKit
import Combine

enum DiarySceneViewActions {
	case didSelectItem(DiarySceneItem)
}

final class DiarySceneView: BaseView {
	// MARK: - Typealiases
	private typealias Datasource = UICollectionViewDiffableDataSource<DiarySceneSection, DiarySceneItem>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<DiarySceneSection, DiarySceneItem>

	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<DiarySceneViewActions, Never>()
	private var datasource: Datasource?

	// MARK: - UI Elements
	private lazy var collectionView = UICollectionView(
		frame: self.bounds,
		collectionViewLayout: makeCollectionViewLayout())

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
	func setupSnapshot(sections: [SectionModel<DiarySceneSection, DiarySceneItem>]) {
		var snapshot = NSDiffableDataSourceSnapshot<DiarySceneSection, DiarySceneItem>()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		datasource?.apply(snapshot)
	}
}

// MARK: - Private extension
private extension DiarySceneView {
	func setupUI() {
		backgroundColor = .black
		setupLayout()
		setupCollectionView()
	}

	func setupCollectionView() {
		collectionView.backgroundColor = .black
		collectionView.register(
			MainSectionHeader.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: MainSectionHeader.reuseId)

		collectionView.register(
			RecordCell.self,
			forCellWithReuseIdentifier: RecordCell.reuseID)

		setupDatasource()
	}

	func setupLayout() {
		addSubview(
			collectionView,
			constraints: [
				collectionView.topAnchor.constraint(equalTo: topAnchor),
				collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
				collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
				collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
			]
		)
	}

	func makeCollectionViewLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] _, _ -> NSCollectionLayoutSection? in
			guard let self = self else {
				return nil
			}
			return makeMainSection()
		}
		return layout
	}

	func makeMainSection() -> NSCollectionLayoutSection {
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
			heightDimension: .fractionalHeight(Constants.defaultGroupSizeHeight))

		let group = NSCollectionLayoutGroup.vertical(
			layoutSize: groupSize,
			subitem: item,
			count: 1)

		let section = NSCollectionLayoutSection(group: group)
		let header = makeSectionHeader()
		section.boundarySupplementaryItems = [header]

		return section
	}

	func makeSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
		let headerSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(Constants.defaultItemSize),
			heightDimension: .fractionalWidth(Constants.defaultHeaderHeight))

		let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: headerSize,
			elementKind: UICollectionView.elementKindSectionHeader,
			alignment: .topLeading)

		sectionHeader.pinToVisibleBounds = true

		return sectionHeader
	}

	// MARK: - Setup datasource
	func setupDatasource() {
		datasource = UICollectionViewDiffableDataSource(
			collectionView: collectionView,
			cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in

			switch item {
			case .record(let model):
				let cell = collectionView.configureCell(
					cellType: RecordCell.self,
					indexPath: indexPath)

				cell.configure(with: model)
				return cell
			}
		})
		datasource?.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
			guard let self = self else {
				return UICollectionReusableView()
			}

			guard kind == UICollectionView.elementKindSectionHeader else {
				return nil
			}
			let sectionHeader = collectionView.dequeueReusableSupplementaryView(
				ofKind: kind,
				withReuseIdentifier: MainSectionHeader.reuseId,
				for: indexPath) as? MainSectionHeader

			let section = self.datasource?.snapshot().sectionIdentifiers[indexPath.section]
			if section?.title == nil {
				return nil
			}
			sectionHeader?.titleLabel.text = section?.title
			
			return sectionHeader
		}
	}

	func bindActions() {
		collectionView.didSelectItemPublisher
			.compactMap { [unowned self] in datasource?.itemIdentifier(for: $0) }
			.map { DiarySceneViewActions.didSelectItem($0) }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}

// MARK: - Constants
private enum Constants {
	static let filterButtonImage = 	   "line.3.horizontal.decrease.circle.fill"
	static let defaultItemSize: 	   CGFloat = 1.0
	static let defaultEdgeInset: 	   CGFloat = 8
	static let defaultGroupSizeHeight: CGFloat = 0.1
	static let defaultHeaderHeight:    CGFloat = 0.08
}

#if DEBUG
// MARK: - SwiftUI preview
import SwiftUI

struct DiaryProvider: PreviewProvider {
	static var previews: some View {
		UIViewControllerPreview {
			let container = AppContainerImpl()
			let vm = DiarySceneViewModel(recordService: container.recordsService,
										 userService: container.userService)
			let viewController = DiarySceneViewController(viewModel: vm)
			return viewController
		}
	}
}
#endif
