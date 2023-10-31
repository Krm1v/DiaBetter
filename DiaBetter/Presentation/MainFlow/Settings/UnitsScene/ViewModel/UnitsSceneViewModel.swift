//
//  UnitsSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.06.2023.
//

import Foundation
import Combine

final class UnitsSceneViewModel: BaseViewModel {
    typealias UnitsSection = SectionModel<UnitsSceneSections, UnitsSceneItems>
    
    // MARK: - Properties
    private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
    private let transitionSubject = PassthroughSubject<UnitsSceneTransitions, Never>()
    private let settingsService: SettingsService
    private let unitsConvertManager: UnitsConvertManager
    private var minGlucoseTarget: Decimal = 2.0
    private var maxGlucoseTarget: Decimal = 22.0
    private var isFirstLoad = false
    private var isConverted = false
    
    // MARK: - @Published properties
    @Published var sections: [UnitsSection] = []
    @Published var carbohydrates: SettingsUnits.CarbsUnits = .breadUnits
    @Published var glucoseUnit: SettingsUnits.GlucoseUnitsState = .mmolL
    
    // MARK: - Init
    init(
        settingsService: SettingsService,
        unitsConvertManager: UnitsConvertManager
    ) {
        self.settingsService = settingsService
        self.unitsConvertManager = unitsConvertManager
    }
    
    // MARK: - Overriden methods
    override func onViewDidLoad() {
        updateCurrentSettings()
        convertCurrentUnits()
    }
    
    override func onViewWillAppear() {
        updateDatasource(minValue: minGlucoseTarget, maxValue: maxGlucoseTarget)
    }
    
    // MARK: - Public methods
    func saveSettings() {
        isCompletedSubject.send(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else {
                return
            }
            
            settingsService.settings = AppSettingsModel(
                notifications: settingsService.settings.notifications,
                glucoseUnits: glucoseUnit,
                carbohydrates: carbohydrates,
                glucoseTarget: .init(min: minGlucoseTarget, max: maxGlucoseTarget))
            
            settingsService.save(settings: settingsService.settings)
            isCompletedSubject.send(false)
        }
    }
    
    func glucoseTargetDidChange(
        _ target: MinMaxGlucoseTarget,
        _ value: Double
    ) {
        switch target {
        case .min:
            minGlucoseTarget = Decimal(value)
            
        case .max:
            maxGlucoseTarget = Decimal(value)
        }
        updateDatasource(minValue: minGlucoseTarget, maxValue: maxGlucoseTarget)
    }
    
    func glucoseUnitDidChange(
        _ unit: SettingsUnits.GlucoseUnitsState
    ) {
        glucoseUnit = unit
    }
}

// MARK: - Private extension
private extension UnitsSceneViewModel {
    func updateDatasource(minValue: Decimal, maxValue: Decimal) {
        let mainSectionModel = UnitsSectionModel(title: "")
        let glucoseTargetSectionModel = UnitsSectionModel(
            title: Localization.targetGlucose)
        
        let glucoseUnitsModel = GlucoseUnitsCellModel(
            title: Localization.glucoseUnits,
            currentUnit: glucoseUnit)
        
        let carbsUnitsModel = CarbsUnitsCellModel(
            title: Localization.carbohydrates,
            currentUnit: carbohydrates)
        
        let mainSection = UnitsSection(
            section: .main(mainSectionModel),
            items: [
                .plainWithSegmentedControl(glucoseUnitsModel),
                .plainWithUIMenu(carbsUnitsModel)
            ])
        
        let minMaxGlucoseModels = buildMinMaxGlucoseModel(min: minValue, max: maxValue)
        
        let glucoseTargetSection = UnitsSection(
            section: .glucoseTarget(glucoseTargetSectionModel),
            items: [
                .plainWithStepper(minMaxGlucoseModels.min),
                .plainWithStepper(minMaxGlucoseModels.max)
            ])
        
        sections = [mainSection, glucoseTargetSection]
    }
    
    func buildMinMaxGlucoseModel(
        min: Decimal,
        max: Decimal
    ) -> (min: TargetGlucoseCellModel, max: TargetGlucoseCellModel) {
        let minGlucose = NSDecimalNumber(decimal: min).doubleValue
        let maxGlucose = NSDecimalNumber(decimal: max).doubleValue
        
        let minGlucoseTargetModel = TargetGlucoseCellModel(
            title: Localization.min,
            value: minGlucose.convertToString(),
            stepperValue: minGlucose,
            type: .min)
        
        let maxGlucoseTargetModel = TargetGlucoseCellModel(
            title: Localization.max,
            value: maxGlucose.convertToString(),
            stepperValue: maxGlucose,
            type: .max)
        
        return (min: minGlucoseTargetModel, max: maxGlucoseTargetModel)
    }
    
    func updateCurrentSettings() {
        carbohydrates = settingsService.settings.carbohydrates
        glucoseUnit = settingsService.settings.glucoseUnits
        if glucoseUnit == .mmolL {
            minGlucoseTarget = settingsService.settings.glucoseTarget.min
            maxGlucoseTarget = settingsService.settings.glucoseTarget.max
        } else {
            minGlucoseTarget = settingsService.settings.glucoseTarget.min / 18
            maxGlucoseTarget = settingsService.settings.glucoseTarget.max / 18
        }
    }
    
    func convertCurrentUnits() {
        $glucoseUnit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else {
                    return
                }
                
                if !isFirstLoad {
                    if state == .mmolL && isConverted {
                        unitsConvertManager.convertValueIfNeeded(
                            &minGlucoseTarget,
                            from: .mgDl,
                            to: .mmolL)
                        
                        unitsConvertManager.convertValueIfNeeded(
                            &maxGlucoseTarget,
                            from: .mgDl,
                            to: .mmolL)
                        
                        isConverted = false
                    } else if state == .mgDl && !isConverted {
                        unitsConvertManager.convertValueIfNeeded(
                            &minGlucoseTarget,
                            from: .mmolL,
                            to: .mgDl)
                        
                        unitsConvertManager.convertValueIfNeeded(
                            &maxGlucoseTarget,
                            from: .mmolL,
                            to: .mgDl)
                        
                        isConverted = true
                    }
                } else {
                    isFirstLoad = false
                }
                
                updateDatasource(
                    minValue: minGlucoseTarget,
                    maxValue: maxGlucoseTarget)
            }
            .store(in: &cancellables)
    }
}
