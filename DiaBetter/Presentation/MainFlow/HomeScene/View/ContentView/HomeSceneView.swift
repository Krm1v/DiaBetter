//
//  HomeSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import UIKit
import Combine

enum HomeSceneActions {
	case addRecordButtonTapped
	case didSelectLineChartState(LineChartState)
}

final class HomeSceneView: BaseView {
	// MARK: - Typealiases
	private typealias Datasource = UICollectionViewDiffableDataSource<ChartSection, ChartsItems>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<ChartSection, ChartsItems>

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
		initialSetup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		bindActions()
		initialSetup()
	}

	// MARK: - Public methods
	func setupAddNewRecordButton(for controller: UIViewController) {
		addNewRecordButton.style = .plain
		addNewRecordButton.image = .add
		addNewRecordButton.tintColor = Colors.customPink.color
		controller.navigationItem.rightBarButtonItem = addNewRecordButton
	}

	func setupSnapshot(with sections: [SectionModel<ChartSection, ChartsItems>]) {
		var snapshot = NSDiffableDataSourceSnapshot<ChartSection, ChartsItems>()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		datasource?.apply(snapshot)
	}
}

// MARK: - Private extension
private extension HomeSceneView {
	func initialSetup() {
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

	func setupCollection() {
		collectionView.register(
			LineChartCell.self,
			forCellWithReuseIdentifier: LineChartCell.reuseID)
		collectionView.register(
			CubicLineChartCell.self,
			forCellWithReuseIdentifier: CubicLineChartCell.reuseID)
		collectionView.register(
			InsulinUsageChartCell.self,
			forCellWithReuseIdentifier: InsulinUsageChartCell.reuseID)
		setupDatasource()
	}

	func makeLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
			guard let self = self else {
				return nil
			}
			guard let sections = ChartSection(rawValue: sectionIndex) else {
				return nil
			}
			switch sections {
			case .lineChart:
				return makeWidgetSection()
			case .cubicLineChart:
				return makeWidgetSection()
			case .insulinUsage:
				return makeWidgetSection()
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
			bottom: .zero,
			trailing: Constants.defaultEdgeInsets)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(Constants.defaultWidgetItemWidth),
			heightDimension: .fractionalWidth(Constants.defaultWidgetGroupWidth))

		let group = NSCollectionLayoutGroup.vertical(
			layoutSize: groupSize,
			subitem: item,
			count: 1)

		let section = NSCollectionLayoutSection(group: group)
		return section
	}

	// MARK: - Datasource
	func setupDatasource() {
		datasource = UICollectionViewDiffableDataSource(
			collectionView: collectionView, cellProvider: { collectionView, indexPath, item -> UICollectionViewCell? in
			switch item {
			case .lineChart(let model):
				let cell = collectionView.configureCell(
					cellType: LineChartCell.self,
					indexPath: indexPath)

				cell.configure(with: model)
				cell.lineChartCellPublisher
					.sink { [unowned self] action in

						switch action {
						case .didSelectState(let state):
							actionSubject.send(.didSelectLineChartState(state))
						}
					}
					.store(in: &cell.cancellables)
				return cell

			case .cubicLineChart(let model):
				let cell = collectionView.configureCell(
					cellType: CubicLineChartCell.self,
					indexPath: indexPath)

				cell.configure(with: model)
				return cell

			case .insulinUsage(let model):
				let cell = collectionView.configureCell(
					cellType: InsulinUsageChartCell.self,
					indexPath: indexPath)
				
				cell.configure(with: model)
				return cell
			}
		})
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
	static let defaultWidgetGroupWidth: CGFloat = 0.6
}

#if DEBUG
// MARK: - SwiftUI preview
import SwiftUI

struct HomeSceneProvider: PreviewProvider {
	static var previews: some View {
		UIViewControllerPreview {
			let container = AppContainerImpl()
			let vm = HomeSceneViewModel(recordService: container.recordsService, userService: container.userService)
			let viewController = HomeSceneViewController(viewModel: vm)
			return viewController
		}
	}
}
#endif
