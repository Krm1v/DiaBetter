//
//  HomeSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import Foundation
import Combine

final class HomeSceneViewModel: BaseViewModel {
	typealias HomeSceneSection = SectionModel<ChartSection, ChartsItems>

	// MARK: - Properties
	private let recordService: RecordsService
	private let userService: UserService
	private let settingsService: SettingsService
	private let unitsConvertManager: UnitsConvertManager
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<HomeSceneTransition, Never>()
	private var lineChartState: LineChartState = .glucose
	private var dateFilterState: WidgetFilterState = .day
	private var currentSettings: AppSettingsModel?
	private var modifiedRecords: [Record] = []

	@Published var sections: [HomeSceneSection] = []
	@Published var records: [Record] = []

	// MARK: - Init
	init(
		recordService: RecordsService,
		userService: UserService,
		settingsService: SettingsService,
		unitsConvertManager: UnitsConvertManager
	) {
		self.recordService = recordService
		self.userService = userService
		self.settingsService = settingsService
		self.unitsConvertManager = unitsConvertManager
	}

	// MARK: - Overriden methods
	override func onViewDidLoad() {
		getCurrentSettings()
	}

	override func onViewWillAppear() {
		fetchRecords()
	}

	// MARK: - Public methods
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

// MARK: - Private extension
private extension HomeSceneViewModel {
	// MARK: - Datasource
	func updateDatasource() {
		let sortedRecords = modifiedRecords.sorted { $0.recordDate < $1.recordDate }

		let barChartModel = buildBarChartCellModel(sortedRecords)
		let barChartSection = HomeSceneSection(
			section: .barChart(nil),
			items: [
				.barChart(barChartModel)
			])

		guard
			let overallGlucose = buidAverageGlucoseWidgetData(for: .overall),
			let weekGlucose = buidAverageGlucoseWidgetData(for: .week),
			let threeMonthGlucose = buidAverageGlucoseWidgetData(for: .threeMonth)
		else {
			return
		}

		let averageGlucoseSectionModel = HomeSectionModel(title: "Average glucose")
		let averageGlucoseSection = HomeSceneSection(
			section: .averageGlucose(averageGlucoseSectionModel),
			items: [
				.averageGlucose(overallGlucose),
				.averageGlucose(weekGlucose),
				.averageGlucose(threeMonthGlucose)
			])

		let lineChartSectionModel = HomeSectionModel(title: "Glucose timeline")

		sections = [
			barChartSection,
			averageGlucoseSection
		]

		guard let lineChartModel = buildLineChartWidgetData() else {
			return
		}
		let lineChartSection = HomeSceneSection(
			section: .lineChart(lineChartSectionModel),
			items: [
				.lineChart(lineChartModel)
			])

		sections = [
			barChartSection,
			averageGlucoseSection,
			lineChartSection
		]
	}

	// MARK: - Network requests
	func fetchRecords() {
		guard let userId = userService.user?.remoteId else {
			return
		}
		recordService.fetchRecords(userId: userId)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					Logger.info("Finished")
					self.updateDatasource()
				case .failure(let error):
					Logger.error(error.localizedDescription)
					errorSubject.send(error)
				}
			} receiveValue: { [weak self] records in
				guard let self = self else {
					return
				}
				self.records = records
			}
			.store(in: &cancellables)
	}

	// MARK: - Setup charts model
	func buildBarChartCellModel(_ sortedRecords: [Record]) -> BarChartCellModel {
		let recordsSource = sortedRecords.filter { Date().isDateInRange($0.recordDate, .month, 1) }

		switch lineChartState {
		case .glucose:
			let items: [BarChartItem] = recordsSource.compactMap { record in
				if let glucoseValue = record.glucoseLevel?.toDouble() {
					return BarChartItem(
						date: record.recordDate,
						yValue: glucoseValue)
				} else {
					return nil
				}
			}

			return BarChartCellModel(
				state: .glucose,
				items: items,
				treshold: currentSettings?.glucoseTarget.max.toDouble())

		case .insulin:
			let items: [BarChartItem] = recordsSource.compactMap { record in
				if let insulinValue = record.fastInsulin?.toDouble() {
					return BarChartItem(
						date: record.recordDate,
						yValue: insulinValue)
				} else {
					return nil
				}
			}
			return BarChartCellModel(state: .insulin, items: items, treshold: nil)

		case .meal:
			let items: [BarChartItem] = recordsSource.compactMap { record in
				if let carbs = record.meal?.toDouble() {
					return BarChartItem(
						date: record.recordDate,
						yValue: carbs)
				} else {
					return nil
				}
			}
			return BarChartCellModel(
				state: .meal,
				items: items,
				treshold: nil)
		}
	}

	// MARK: - Average glucose data
	func buidAverageGlucoseWidgetData(for period: AverageGlucosePeriods) -> AverageGlucoseCellModel? {
		var recordsSource: [Record] = []
		switch period {
		case .overall:
			recordsSource = modifiedRecords
		case .week:
			let filteredRecords = modifiedRecords.filter { Date().isDateInRange($0.recordDate, .day, 7) }
			recordsSource = filteredRecords.sorted { $0.recordDate < $1.recordDate }
		case .threeMonth:
			let filteredRecords = modifiedRecords.filter { Date().isDateInRange($0.recordDate, .month, 3) }
			recordsSource = filteredRecords.sorted { $0.recordDate < $1.recordDate }
		}

		let averageValue = findAverageValue(
			from: recordsSource,
			count: recordsSource.count)

		guard let currentSettings = currentSettings else {
			return nil
		}

		var model = AverageGlucoseCellModel(
			period: period,
			glucoseValue: averageValue.convertToString(),
			glucoseUnit: currentSettings.glucoseUnits.title,
			dotColor: Colors.customMint.color)

		let target = currentSettings.glucoseTarget
		let range = target.min...target.max

		if range ~= averageValue {
			model.dotColor = Colors.customMint.color
		} else if averageValue < target.min {
			model.dotColor = Colors.customLightBlue.color
		} else {
			model.dotColor = Colors.customPink.color
		}
		return model
	}

	func buildLineChartWidgetData() -> LineChartCellModel? {
		let sortedRecords = records.sorted { $0.recordDate < $1.recordDate }
		let recordsSource = sortedRecords.filter { Date().isDateInRange($0.recordDate, .month, 1) }

		var items: [LineChartItem] = recordsSource.compactMap { record in
			if let glucose = record.glucoseLevel?.toDouble() {
				return LineChartItem(date: record.recordDate, yValue: glucose)
			} else {
				return nil
			}
		}
		let sortedValues = items.sorted { $0.yValue > $1.yValue }

		return LineChartCellModel(items: items)
	}

	// MARK: - Helpers
	func getCurrentSettings() {
		let combinedData = Publishers.CombineLatest(settingsService.settingsPublisher, $records)
		combinedData
			.receive(on: DispatchQueue.main)
			.sink { [weak self] settings, records in
				guard let self = self else {
					return
				}
				self.currentSettings = settings
				self.modifiedRecords = records.compactMap({ record in
					var modifiedRecord = record

					if let glucose = record.glucoseLevel {
						modifiedRecord.glucoseLevel = self.unitsConvertManager.convertRecordUnits(
							glucoseValue: glucose)
					}

					if let carbs = record.meal {
						modifiedRecord.meal = self.unitsConvertManager.convertRecordUnits(
							carbs: carbs)
					}
					return modifiedRecord
				})
				updateDatasource()
			}
			.store(in: &cancellables)
	}

	func findAverageValue(from records: [Record], count: Int) -> Decimal {
		let summaryValue = records.reduce(Decimal.zero) { partialResult, record in
			guard let glucose = record.glucoseLevel else {
				return partialResult
			}
			return partialResult + glucose
		}

		let averageValue = summaryValue / Decimal(count)
		return averageValue
	}
}
