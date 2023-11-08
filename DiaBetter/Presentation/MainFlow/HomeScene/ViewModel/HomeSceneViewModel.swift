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
    
    @Published var homeSceneProps: HomeSceneWidgetPropsModel?
    
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
        var glucoseModel: GlucoseBarChartModel?
        var lineChartData: LineChartHomeWidgetModel?
        var averageGlucoseData = [AverageGlucoseChartModel]()
        
        if let model = buildGlucoseBarChartModel(from: records) {
            glucoseModel = model
        }
        
        if let data = buildLineChartWidgetData(from: records) {
            lineChartData = data
        }
        
        if let overallAverage = buildAverageGlucoseWidgetData(
            from: records,
            for: .overall
        ) {
            averageGlucoseData.append(overallAverage)
        }
        
        if let threeMonthAverage = buildAverageGlucoseWidgetData(
            from: records,
            for: .threeMonth
        ) {
            averageGlucoseData.append(threeMonthAverage)
        }
        
        if let weekAverage = buildAverageGlucoseWidgetData(
            from: records,
            for: .week
        ) {
            averageGlucoseData.append(weekAverage)
        }
        
        let isAverageDataAvailable = !averageGlucoseData.isEmpty
        
        let newProps = HomeSceneWidgetPropsModel(
            glucoseChartModel: glucoseModel ?? .init(data: [],
                                                     treshold: 0),
            averageGlucoseChartModel: .init(data: averageGlucoseData,
                                            isData: isAverageDataAvailable),
            lineChartHomeWidgetModel: lineChartData ?? .init(data: [])
        )
        
        homeSceneProps = newProps
    }
}

// MARK: - Private extension
private extension HomeSceneViewModel {
    // MARK: - Datasource
    // MARK: - Setup charts model
    func buildGlucoseBarChartModel(from records: [Record]) -> GlucoseBarChartModel? {
        let lastWeekRecords = getLastWeekRecords(with: records)
        guard let treshold = currentSettings?.glucoseTarget.max.toDouble() else {
            return nil
        }
        let items = lastWeekRecords.compactMap { record in
            if let glucose = record.glucoseLevel?.toDouble() {
                return ChartItem(
                    xValue: record.recordDate,
                    yValue: glucose)
            } else {
                return nil
            }
        }
        
        return GlucoseBarChartModel(data: items, treshold: treshold)
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
        
        let averageStringValue = !averageValue.isNaN ? averageValue.convertToString() : ""
        
        guard let currentSettings = currentSettings else {
            return nil
        }
        
        var model = AverageGlucoseChartModel(
            averageValue: averageStringValue,
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
    
    func buildLineChartWidgetData(
        from records: [Record]
    ) -> LineChartHomeWidgetModel? {
        let sortedRecords = records.sorted { $0.recordDate < $1.recordDate }
        let recordsSource = getLastWeekRecords(with: sortedRecords)
        
        let items = recordsSource.compactMap { record in
            if let glucose = record.glucoseLevel?.toDouble() {
                return ChartItem(xValue: record.recordDate, yValue: glucose)
            } else {
                return nil
            }
        }
        
        return LineChartHomeWidgetModel(data: items)
    }
    
    // MARK: - Helpers
    func findAverageValue(from records: [Record], count: Int) -> Decimal {
        let recordsWithGlucose = records.filter { $0.glucoseLevel != nil }
        
        let summaryValue = recordsWithGlucose.reduce(Decimal.zero) { partialResult, record in
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
            return lastWeekRecords.sorted { $0.recordDate < $1.recordDate }
        }
        return []
    }
    
    func getCurrentRecords() {
        $modifiedRecords
            .subscribe(on: DispatchQueue.global())
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
