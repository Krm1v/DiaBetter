//
//  HomeSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import Foundation
import Combine

final class HomeSceneViewModel: BaseViewModel {
	//MARK: - Properties
	private let recordService: RecordsService
	private let userService: UserService
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<HomeSceneTransition, Never>()
	private var lineChartState: LineChartState = .glucose
	private var dateFilterState: WidgetFilterState = .day
	
	@Published var sections: [SectionModel<ChartSection, ChartsItems>] = []
	@Published var records: [Record] = []
	
	//MARK: - Init
	init(recordService: RecordsService, userService: UserService) {
		self.recordService = recordService
		self.userService = userService
	}
	
	//MARK: - Overriden methods
	override func onViewWillAppear() {
		fetchRecords()
	}
	
	//MARK: - Public methods
	func openAddNewRecordScene() {
		transitionSubject.send(.toAddRecordScene)
	}
	
	func didSelectLineChartState(_ state: LineChartState) {
		self.lineChartState = state
		updateDatasource()
	}
	
	func didSelectChartFilterState(_ filterState: WidgetFilterState) {
		self.dateFilterState = filterState
		updateDatasource()
	}
}

//MARK: - Private extension
private extension HomeSceneViewModel {
	func updateDatasource() {
		let sortedRecords = records.sorted { $0.recordDate ?? Date() < $1.recordDate ?? Date() }
		let lineChartModel = setupLineChartCellModel(sortedRecords)
		let lineChartSection = SectionModel<ChartSection, ChartsItems>(
			section: .lineChart,
			items: [
				.lineChart(lineChartModel)
			]
		)
		
		let cubicBezierLineChartModel = setupCubicBezierCellModel(sortedRecords)
		let cubicLineChartSection = SectionModel<ChartSection, ChartsItems>(
			section: .cubicLineChart,
			items: [
				.cubicLineChart(cubicBezierLineChartModel)
			]
		)
		
		let insulinUsageChartModel = setupInsulineUsageChartModel(sortedRecords)
		let insulinUsageSection = SectionModel<ChartSection, ChartsItems>(
			section: .insulinUsage,
			items: [
				.insulinUsage(insulinUsageChartModel)
			]
		)
		sections = [lineChartSection, cubicLineChartSection, insulinUsageSection]
	}
	
	func fetchRecords() {
		guard let userId = userService.user?.remoteId else { return }
		recordService.fetchRecords(userId: userId)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					Logger.info("Finished", shouldLogContext: true)
					self.updateDatasource()
				case .failure(let error):
					Logger.error(error.localizedDescription)
					errorSubject.send(error)
				}
			} receiveValue: { [weak self] records in
				guard let self = self else { return }
				self.records = records
			}
			.store(in: &cancellables)
	}
	
	func setupLineChartCellModel(_ sortedRecords: [Record]) -> LineChartCellModel {
		switch lineChartState {
		case .glucose:
			let items = sortedRecords.map {
				ChartItem(
					x: $0.recordDate?.toDouble() ?? .zero,
					y: $0.glucoseLevel?.toDouble() ?? .zero)
			}
			return LineChartCellModel(state: .glucose, items: items)
		case .insulin:
			let items = sortedRecords.map {
				ChartItem(
					x: $0.recordDate?.toDouble() ?? .zero,
					y: $0.fastInsulin?.toDouble() ?? .zero)
			}
			return LineChartCellModel(state: .insulin, items: items)
		case .meal:
			let items = sortedRecords.map {
				ChartItem(
					x: $0.recordDate?.toDouble() ?? .zero,
					y: $0.meal?.toDouble() ?? .zero)
			}
			return LineChartCellModel(state: .meal, items: items)
		}
	}
	
	func setupCubicBezierCellModel(_ sortedRecords: [Record]) -> GlucoseLevelPerPeriodWidgetModel {
		let items = sortedRecords.map {
			ChartItem(
				x: $0.recordDate?.toDouble() ?? .zero,
				y: $0.glucoseLevel?.toDouble() ?? .zero)
		}
			.filter({ $0.y != .zero })
		switch dateFilterState {
		case .day:
			return GlucoseLevelPerPeriodWidgetModel(filter: .day, items: items)
		case .week:
			return GlucoseLevelPerPeriodWidgetModel(filter: .week, items: items)
		case .month:
			return GlucoseLevelPerPeriodWidgetModel(filter: .month, items: items)
		}
	}
	
	func setupInsulineUsageChartModel(_ sortedRecords: [Record]) -> InsulinUsageChartModel {
		let fastInsulin = sortedRecords.map {
			ChartItem(
				x: $0.recordDate?.toDouble() ?? .zero,
				y: $0.fastInsulin?.toDouble() ?? .zero)
		}
		let basalInsulin = sortedRecords.map {
			ChartItem(
				x: $0.recordDate?.toDouble() ?? .zero,
				y: $0.longInsulin?.toDouble() ?? .zero)
		}
		switch dateFilterState {
		case .day:
			return InsulinUsageChartModel(filter: .day,
										  fastInsulin: fastInsulin,
										  basalInsulin: basalInsulin)
		case .week:
			return InsulinUsageChartModel(filter: .week,
										  fastInsulin: fastInsulin,
										  basalInsulin: basalInsulin)
		case .month:
			return InsulinUsageChartModel(filter: .day,
										  fastInsulin: fastInsulin,
										  basalInsulin: basalInsulin)
		}
	}
}
