//
//  HomeSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import UIKit
import SwiftUI
import Combine

enum HomeSceneActions {
	case addRecordButtonTapped
	case widgetModeDidChanged(LineChartState)
}

final class HomeSceneView: BaseView {
	// MARK: - Typealiases
	private typealias Datasource = UICollectionViewDiffableDataSource<ChartSection, ChartsItems>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<ChartSection, ChartsItems>
	private typealias Registration = UICollectionView.CellRegistration<UICollectionViewCell, ChartsItems>
	typealias HomeSceneSectionModel = SectionModel<ChartSection, ChartsItems>

	// MARK: - Propertiеs
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<HomeSceneActions, Never>()
	private var datasource: Datasource?

	// MARK: - UIElements
	private lazy var addNewRecordButton = buildNavBarButton()
	private lazy var collectionView = UICollectionView(frame: self.bounds,
													   collectionViewLayout: makeLayout())

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		bindActions()
		setupUI()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		bindActions()
		setupUI()
	}

	// MARK: - Public methods
	func setupAddNewRecordButton(for controller: UIViewController) {
		addNewRecordButton.style = .plain
		addNewRecordButton.image = .add
		addNewRecordButton.tintColor = Colors.customPink.color
		controller.navigationItem.rightBarButtonItem = addNewRecordButton
	}

	func setupSnapshot(with sections: [HomeSceneSectionModel]) {
		var snapshot = Snapshot()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		datasource?.apply(snapshot)
	}
}

// MARK: - Private extension
private extension HomeSceneView {
	// MARK: - Setup UI
	func setupUI() {
		backgroundColor = .black
		setupLayout()
		setupCollection()
	}

	func setupLayout() {
		addSubview(collectionView, constraints: [
			collectionView.topAnchor.constraint(equalTo: self.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	// MARK: - CollectionView setup methods
	func setupCollection() {
		setupDatasource()
		collectionView.register(
			HomeSectionHeader.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: HomeSectionHeader.reuseId)
	}

	// MARK: - Layout setup methods
	func makeLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
			guard let self = self else {
				return nil
			}
			guard let sections = ChartSection(rawValue: sectionIndex) else {
				return nil
			}
			switch sections {
			case .barChart:
				return makeWidgetSection()
			case .averageGlucose:
				return makeAverageGlucoseSection()
			case .lineChart:
				return makeLineChartSection()
			}
		}
		return layout
	}

	func makeWidgetSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(Constants.defaultWidgetItemWidth),
			heightDimension: .fractionalHeight(Constants.defaultWidgetItemHeight))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		item.contentInsets = NSDirectionalEdgeInsets(
			top: Constants.defaultEdgeInsets,
			leading: .zero,
			bottom: 8,
			trailing: .zero)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(Constants.defaultWidgetItemWidth),
			heightDimension: .fractionalWidth(Constants.defaultWidgetGroupWidth))

		let group = NSCollectionLayoutGroup.vertical(
			layoutSize: groupSize,
			subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		return section
	}

	func makeAverageGlucoseSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0 / 3),
			heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		item.contentInsets = NSDirectionalEdgeInsets(
			top: Constants.defaultEdgeInsets,
			leading: .zero,
			bottom: 8,
			trailing: .zero)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalWidth(0.3))

		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: groupSize,
			subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		let header = makeSectionHeader()
		section.boundarySupplementaryItems = [header]

		return section
	}

	func makeLineChartSection() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(Constants.defaultWidgetItemWidth),
			heightDimension: .fractionalHeight(Constants.defaultWidgetItemHeight))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		item.contentInsets = NSDirectionalEdgeInsets(
			top: Constants.defaultEdgeInsets,
			leading: .zero,
			bottom: 8,
			trailing: .zero)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(Constants.defaultWidgetItemWidth),
			heightDimension: .fractionalWidth(Constants.defaultWidgetGroupWidth))

		let group = NSCollectionLayoutGroup.vertical(
			layoutSize: groupSize,
			subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		let header = makeSectionHeader()

		section.boundarySupplementaryItems = [header]
		return section
	}

	func makeSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
		let headerSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalWidth(0.08))

		let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: headerSize,
			elementKind: UICollectionView.elementKindSectionHeader,
			alignment: .topLeading)

		return sectionHeader
	}

	// MARK: - Datasource
	func setupDatasource() {
		let cellRegistration = registerCells()
		datasource = UICollectionViewDiffableDataSource(
			collectionView: collectionView, cellProvider: { collectionView, indexPath, item -> UICollectionViewCell? in
				switch item {
				case .barChart:
					let cell = collectionView.dequeueConfiguredReusableCell(
						using: cellRegistration,
						for: indexPath,
						item: item)

					return cell
					
				case .averageGlucose:
					let cell = collectionView.dequeueConfiguredReusableCell(
						using: cellRegistration,
						for: indexPath,
						item: item)

					return cell

				case .lineChart:
					let cell = collectionView.dequeueConfiguredReusableCell(
						using: cellRegistration,
						for: indexPath,
						item: item)

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
				withReuseIdentifier: HomeSectionHeader.reuseId,
				for: indexPath) as? HomeSectionHeader

			let section = self.datasource?.snapshot().sectionIdentifiers[indexPath.section]
			if section?.title == nil {
				return nil
			}
			sectionHeader?.titleText = section?.title

			return sectionHeader
		}
	}

	// MARK: - Cell registration
	private func registerCells() -> Registration {
		let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ChartsItems> { cell, _, itemIdentifier in
			switch itemIdentifier {
			case .barChart(let model):
				cell.contentConfiguration = nil
				cell.contentConfiguration = UIHostingConfiguration(content: {
					var content = BarChart(model: model, pickerState: model.state, treshold: model.treshold)
					content.onReceive(content.chartActionPublisher) { [weak self] action in
						guard let self = self else {
							return
						}
						switch action {
						case .segmentedDidPressed(let pickerContent):
							self.actionSubject.send(.widgetModeDidChanged(pickerContent))
						}
					}
				})

			case .averageGlucose(let model):
				cell.contentConfiguration = nil
				cell.contentConfiguration = UIHostingConfiguration(content: {
					AverageGlucoseCell(model: model)
				})

			case .lineChart(let model):
				cell.contentConfiguration = nil
				cell.contentConfiguration = UIHostingConfiguration(content: {
					LineChartCell(model: model)
				})
			}
		}

		return cellRegistration
	}

	// MARK: - Actions binding
	func bindActions() {
		addNewRecordButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.addRecordButtonTapped)
			}
			.store(in: &cancellables)
	}
}

// MARK: - Constants
private enum Constants {
	static let defaultWidgetItemWidth: CGFloat = 1.0
	static let defaultWidgetItemHeight: CGFloat = 1.0
	static let defaultEdgeInsets: CGFloat = 16
	static let defaultWidgetGroupWidth: CGFloat = 0.7
}
