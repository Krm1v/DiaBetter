//
//  HomeSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import Foundation
import Combine

final class HomeSceneViewModel: ChartsViewModel {
	typealias HomeSceneSection = SectionModel<ChartSection, ChartsItems>

	// MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<HomeSceneTransition, Never>()
	private var lineChartState: LineChartState = .glucose
	private var dateFilterState: WidgetFilterState = .day
    private var currentRecords: [Record] = []

	@Published var sections: [HomeSceneSection] = []

	// MARK: - Init
    init(
        userService: UserService,
        recordsService: RecordsService,
        settingsService: SettingsService,
        unitsConvertManager: UnitsConvertManager
    ) {
        super.init(
            recordsService: recordsService,
            userService: userService,
            settingsService: settingsService,
            unitsConvertManager: unitsConvertManager)
	}

	// MARK: - Overriden methods
	override func onViewDidLoad() {
        super.onViewDidLoad()
        getCurrentRecords()
	}

	// MARK: - Public methods
	func openAddNewRecordScene() {
		transitionSubject.send(.toAddRecordScene)
	}

	func didSelectLineChartState(_ state: LineChartState) {
		self.lineChartState = state
        updateDatasource(with: currentRecords)
	}

	func didSelectChartFilterState(_ filterState: WidgetFilterState) {
		self.dateFilterState = filterState
		updateDatasource(with: currentRecords)
	}
}

// MARK: - Private extension
private extension HomeSceneViewModel {
	// MARK: - Datasource
    func updateDatasource(with records: [Record]) {
        let modifiedRecords = modifiedRecords.sorted { $0.recordDate < $1.recordDate }
		let barChartModel = buildBarChartCellModel(modifiedRecords)
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

        let averageGlucoseSectionModel = HomeSectionModel(title: Localization.averageGlucose)
		let averageGlucoseSection = HomeSceneSection(
			section: .averageGlucose(averageGlucoseSectionModel),
			items: [
				.averageGlucose(overallGlucose),
				.averageGlucose(weekGlucose),
				.averageGlucose(threeMonthGlucose)
			])

        let lineChartSectionModel = HomeSectionModel(title: Localization.glucoseTimeline)

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

        let items: [LineChartItem] = recordsSource.compactMap { record in
			if let glucose = record.glucoseLevel?.toDouble() {
				return LineChartItem(date: record.recordDate, yValue: glucose)
			} else {
				return nil
			}
		}

		return LineChartCellModel(items: items)
	}

	// MARK: - Helpers
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
    
    func getCurrentRecords() {
        $modifiedRecords
            .receive(on: DispatchQueue.main)
            .sink { [weak self] modifiedRecords in
                guard let self = self else {
                    return
                }
                self.updateDatasource(with: modifiedRecords)
                self.currentRecords = modifiedRecords
            }
            .store(in: &cancellables)
    }
}
