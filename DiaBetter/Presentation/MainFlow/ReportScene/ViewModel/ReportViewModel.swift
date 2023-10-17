//
//  ReportViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.03.2023.
//

import Foundation
import Combine

final class ReportViewModel: ChartsViewModel {
    // MARK: - Properties
    private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
    private let transitionSubject = PassthroughSubject<ReportTransition, Never>()
    
    // MARK: - Published properties
    @Published var reportScenePropsModel: ReportSceneProps = .init(
        areaChartModel: .init(),
        insulinBarChartModel: .init(),
        averageGlucoseChartModel: .init(glucoseValue: "", glucoseUnit: ""),
        minMaxGlucoseValueChartModel: .init(minValue: "", maxValue: ""))
    
    // MARK: - Init
    override init(
        recordsService: RecordsService,
        userService: UserService,
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
}

// MARK: - Private extension
private extension ReportViewModel {
    func setupChartsDatasource(with records: [Record]) {
        setupAreaChartModel(with: records)
        setupInsulinBarChartModel(with: records)
        setupAverageGlucoseChartModel(with: records)
        setupMinMaxGlucoseValueChartModel(with: records)
    }
    
    func setupAreaChartModel(with records: [Record]) {
        let data: [TodayAreaChartModel] = records.compactMap { record in
            if let glucoseValue = record.glucoseLevel?.toDouble() {
                return TodayAreaChartModel(
                    glucoseValue: glucoseValue,
                    recordTime: record.recordDate)
            } else {
                return nil
            }
        }
        reportScenePropsModel.areaChartModel = data
        reportScenePropsModel.treshold = currentSettings?.glucoseTarget.max.toDouble()
    }
    
    func setupInsulinBarChartModel(with records: [Record]) {
        let fastInsulinItems: [InsulinChartModel] = records.compactMap { record in
            return InsulinChartModel(
                recordTime: record.recordDate,
                insulinValue: record.fastInsulin?.toDouble() ?? .zero)
        }
        
        let basalInsulinItems: [InsulinChartModel] = records.compactMap { record in
            return InsulinChartModel(
                recordTime: record.recordDate,
                insulinValue: record.longInsulin?.toDouble() ?? .zero)
        }
        
        let fastInsulinTitle = userService.user?.fastActingInsulin ?? Localization.fastActingInsulin
        let basalInsulinTitle = userService.user?.basalInsulin ?? Localization.basalInsulin
        
        reportScenePropsModel.insulinBarChartModel = [
            TodayInsulinChartModel(insulinType: .fast(fastInsulinTitle), data: fastInsulinItems),
            TodayInsulinChartModel(insulinType: .basal(basalInsulinTitle), data: basalInsulinItems)
        ]
    }
    
    func setupAverageGlucoseChartModel(with records: [Record]) {
        let summaryValue = records.reduce(Decimal.zero) { partialResult, record in
            guard let glucoseValue = record.glucoseLevel else {
                return partialResult
            }
            return partialResult + glucoseValue
        }
        
        let averageValue = summaryValue / Decimal(records.count)
        
        var averageGlucoseChartModel = TodayAverageGlucoseChartModel(
            glucoseValue: averageValue.convertToString(),
            dotColor: Colors.customMint.color,
            glucoseUnit: currentSettings?.glucoseUnits.title ?? "")
        
        guard let target = currentSettings?.glucoseTarget else {
            return
        }
        
        let range = target.min...target.max
        
        if range ~= averageValue {
            averageGlucoseChartModel.dotColor = Colors.customMint.color
        } else if averageValue < target.min {
            averageGlucoseChartModel.dotColor = Colors.customLightBlue.color
        } else {
            averageGlucoseChartModel.dotColor = Colors.customPink.color
        }
        
        reportScenePropsModel.averageGlucoseChartModel = averageGlucoseChartModel
    }
    
    func setupMinMaxGlucoseValueChartModel(with records: [Record]) {
        let glucoseValues = records.compactMap { $0.glucoseLevel }
        guard
            let minValue = glucoseValues.min()?.convertToString(),
            let maxValue = glucoseValues.max()?.convertToString()
        else {
            return
        }
        
        var minMaxGlucoseValueChartModel = TodayMinMaxGlucoseValuesChartModel(
            minValue: minValue,
            maxValue: maxValue)
        
        reportScenePropsModel.minMaxGlucoseValueChartModel = minMaxGlucoseValueChartModel
    }
    
    func getTodaysRecords(with records: [Record]) -> [Record] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let todaysRecords = records.filter { record in
            return calendar.isDate(record.recordDate, inSameDayAs: currentDate)
        }
        
        return todaysRecords
    }
    
    func getCurrentRecords() {
        $modifiedRecords
            .receive(on: DispatchQueue.main)
            .sink { [weak self] modifiedRecords in
                guard let self = self else {
                    return
                }
                let records = getTodaysRecords(with: modifiedRecords)
                setupChartsDatasource(with: records)
            }
            .store(in: &cancellables)
    }
}
