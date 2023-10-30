//
//  HomeSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import Foundation
import Combine

final class HomeSceneViewModel: ChartsViewModel {
    
    // MARK: - Properties
    private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
    private let transitionSubject = PassthroughSubject<HomeSceneTransition, Never>()
    private var currentRecords: [Record] = []
    
    @Published var homeSceneProps = HomeSceneWidgetPropsModel(
        glucoseChartModel: .init(data: [], treshold: 0),
        averageGlucoseChartModel: [],
        lineChartHomeWidgetModel: .init(data: []))
    
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
    
    func setupChartsDatasource(with records: [Record]) {
        buildGlucoseBarChartModel(from: records)
        guard
            let overallAverage = buildAverageGlucoseWidgetData(
                from: records,
                for: .overall),
            let threeMonthAverage = buildAverageGlucoseWidgetData(
                from: records,
                for: .threeMonth),
            let weekAverage = buildAverageGlucoseWidgetData(
                from: records,
                for: .week)
        else {
            return
        }
        
        homeSceneProps.averageGlucoseChartModel = [overallAverage, threeMonthAverage, weekAverage]
        
        buildLineChartWidgetData(from: records)
    }
}

// MARK: - Private extension
private extension HomeSceneViewModel {
    // MARK: - Datasource
    // MARK: - Setup charts model
    func buildGlucoseBarChartModel(from records: [Record]) {
        let lastWeekRecords = getLastWeekRecords(with: records)
        guard let treshold = currentSettings?.glucoseTarget.max.toDouble() else {
            return
        }
        let items = lastWeekRecords.compactMap { record in
            if let glucose = record.glucoseLevel?.toDouble() {
                return ChartItem(xValue: record.recordDate, yValue: glucose)
            } else {
                return nil
            }
        }
        
        let model = GlucoseBarChartModel(data: items, treshold: treshold)
        homeSceneProps.glucoseChartModel = model
    }
    
    // MARK: - Average glucose data
    func buildAverageGlucoseWidgetData(
        from records: [Record],
        for period: AverageGlucoseChartModel.RecordsPeriod
    ) -> AverageGlucoseChartModel? {
        var recordsSource: [Record] = []
        switch period {
        case .overall:
            recordsSource = records
        case .week:
            let filteredRecords = records.filter { Date().isDateInRange($0.recordDate, .day, 7) }
            recordsSource = filteredRecords.sorted { $0.recordDate < $1.recordDate }
        case .threeMonth:
            let filteredRecords = records.filter { Date().isDateInRange($0.recordDate, .month, 3) }
            recordsSource = filteredRecords.sorted { $0.recordDate < $1.recordDate }
        }
        
        let averageValue = findAverageValue(
            from: recordsSource,
            count: recordsSource.count)
        
        guard let currentSettings = currentSettings else {
            return nil
        }
        
        var model = AverageGlucoseChartModel(
            averageValue: averageValue.convertToString(),
            glucoseUnit: currentSettings.glucoseUnits,
            period: period)
        
        let target = currentSettings.glucoseTarget
        let range = target.min...target.max
        
        if range ~= averageValue {
            model.dotColor = Colors.customGreen.color
        } else if averageValue < target.min {
            model.dotColor = Colors.customPurple.color
        } else {
            model.dotColor = Colors.customPink.color
        }
        
        return model
    }
    
    func buildLineChartWidgetData(from records: [Record]) {
        let sortedRecords = records.sorted { $0.recordDate < $1.recordDate }
        let recordsSource = getLastWeekRecords(with: sortedRecords)
        
        let items = recordsSource.compactMap { record in
            if let glucose = record.glucoseLevel?.toDouble() {
                return ChartItem(xValue: record.recordDate, yValue: glucose)
            } else {
                return nil
            }
        }
        
        let model = LineChartHomeWidgetModel(data: items)
        homeSceneProps.lineChartHomeWidgetModel = model
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
    
    func getLastWeekRecords(with records: [Record]) -> [Record] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        if let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: currentDate) {
            let lastWeekRecords = records.filter { record in
                return oneWeekAgo...currentDate ~= record.recordDate
            }
            return lastWeekRecords
        }
        return []
    }
    
    func getCurrentRecords() {
        $modifiedRecords
            .receive(on: DispatchQueue.main)
            .sink { [weak self] modifiedRecords in
                guard let self = self else {
                    return
                }
                setupChartsDatasource(with: modifiedRecords)
            }
            .store(in: &cancellables)
    }
}
