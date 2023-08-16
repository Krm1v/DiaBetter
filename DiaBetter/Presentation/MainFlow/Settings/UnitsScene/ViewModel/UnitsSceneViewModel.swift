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
	private let appSettingsService: SettingsService
	@Published var sections: [UnitsSection] = []
	@Published var carbohydrates: SettingsUnits.CarbsUnits = .breadUnits
	@Published var glucoseUnit: SettingsUnits.GlucoseUnitsState = .mmolL
	@Published var minGlucoseTarget: Decimal = 2.0
	@Published var maxGlucoseTarget: Decimal = 22.0

	// MARK: - Init
	init(appSettingsService: SettingsService) {
		self.appSettingsService = appSettingsService
	}

	// MARK: - Overriden methods
	override func onViewDidLoad() {
		updateCurrentSettings()
	}

	override func onViewWillAppear() {
		updateDatasource()
	}

	// MARK: - Public methods
	func saveSettings() {
		appSettingsService.settings = AppSettingsModel(
			notifications: appSettingsService.settings.notifications,
			glucoseUnits: glucoseUnit,
			carbohydrates: carbohydrates,
			glucoseTarget: .init(min: minGlucoseTarget, max: maxGlucoseTarget))

		appSettingsService.save(settings: appSettingsService.settings)
	}

	func glucoseTargetDidChanged(
		_ target: MinMaxGlucoseTarget,
		_ value: Double
	) {
		switch target {
		case .min:
			minGlucoseTarget = Decimal(value)

		case .max:
			maxGlucoseTarget = Decimal(value)
		}
		updateDatasource()
	}
}

// MARK: - Private extension
private extension UnitsSceneViewModel {
	func updateDatasource() {
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
				.plainWithUIMenu(carbsUnitsModel)])

		let minGlucose = NSDecimalNumber(decimal: minGlucoseTarget).doubleValue
		let maxGlucose = NSDecimalNumber(decimal: maxGlucoseTarget).doubleValue

		let minGlucoseTargetModel = TargetGlucoseCellModel(
			title: Localization.min,
			value: minGlucoseTarget.convertToString(),
			stepperValue: minGlucose,
			type: .min)

		let maxGlucoseTargetModel = TargetGlucoseCellModel(
			title: Localization.max,
			value: maxGlucoseTarget.convertToString(),
			stepperValue: maxGlucose,
			type: .max)

		let glucoseTargetSection = UnitsSection(
			section: .glucoseTarget(glucoseTargetSectionModel),
			items: [
				.plainWithStepper(minGlucoseTargetModel),
				.plainWithStepper(maxGlucoseTargetModel)])

		sections = [mainSection, glucoseTargetSection]
	}
	
	func updateCurrentSettings() {
		carbohydrates = appSettingsService.settings.carbohydrates
		glucoseUnit = appSettingsService.settings.glucoseUnits
		minGlucoseTarget = appSettingsService.settings.glucoseTarget.min
		maxGlucoseTarget = appSettingsService.settings.glucoseTarget.max
	}
}
