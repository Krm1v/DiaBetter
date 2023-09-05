//
//  UnitsConverterManager.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 30.08.2023.
//

import Foundation
import Combine

protocol UnitsConvertManager: AnyObject {
	func convertRecordUnits(glucoseValue: Decimal) -> Decimal
	func convertRecordUnits(carbs: Decimal) -> Decimal
	func setToDefaultValue(glucoseValue: Decimal?) -> AnyPublisher<Decimal?, Never>
	func setToDefaultValue(carbs: Decimal?) -> AnyPublisher<Decimal?, Never>
}

final class UnitsConvertManagerImpl {
	// MARK: - Properties
	private var settingsService: SettingsService
	private var cancellables = Set<AnyCancellable>()

	// MARK: - Init
	init(settingsService: SettingsService) {
		self.settingsService = settingsService
	}
}

// MARK: - Extension UnitsConverterManager
extension UnitsConvertManagerImpl: UnitsConvertManager {
	func convertRecordUnits(glucoseValue: Decimal) -> Decimal {
		return convertGlucoseUnits(glucoseValue: glucoseValue)
	}

	func convertRecordUnits(carbs: Decimal) -> Decimal {
		return convertCarbsUnits(carbs: carbs)
	}

	func setToDefaultValue(glucoseValue: Decimal?) -> AnyPublisher<Decimal?, Never> {
		var updatedGlucose: Decimal?
		return settingsService.settingsPublisher
			.map { settings in
				switch settings.glucoseUnits {
				case .mmolL:
					updatedGlucose = glucoseValue
					return updatedGlucose
				case .mgDl:
					if let glucoseValue {
						updatedGlucose = glucoseValue / 18
					}
					return updatedGlucose
				}
			}
			.eraseToAnyPublisher()
	}

	func setToDefaultValue(carbs: Decimal?) -> AnyPublisher<Decimal?, Never> {
		var updatedCarbs: Decimal?
		return settingsService.settingsPublisher
			.map { settings in
				switch settings.carbohydrates {
				case .breadUnits:
					updatedCarbs = carbs
					return updatedCarbs
				case .grams:
					if let carbs {
						updatedCarbs = carbs / 12
					}
					return updatedCarbs
				}
			}
			.eraseToAnyPublisher()
	}
}

// MARK: - Private extension
private extension UnitsConvertManagerImpl {
	func convertGlucoseUnits(glucoseValue: Decimal) -> Decimal {
		var modifiedGlucoseValue = Decimal()
		settingsService.settingsPublisher
			.sink { settings in
				switch settings.glucoseUnits {
				case .mmolL:
					modifiedGlucoseValue = glucoseValue
				case .mgDl:
					modifiedGlucoseValue = glucoseValue * Constants.mgDlConversionFactor
				}
			}
			.store(in: &cancellables)
		return modifiedGlucoseValue
	}

	func convertCarbsUnits(carbs: Decimal) -> Decimal {
		var modifiedMealValue = Decimal()
		settingsService.settingsPublisher
			.sink { setting in
				switch setting.carbohydrates {
				case .breadUnits:
					modifiedMealValue = carbs
				case .grams:
					modifiedMealValue = carbs * Constants.gramsConversionFactor
				}
			}
			.store(in: &cancellables)
		return modifiedMealValue
	}
}

// MARK: - Constants
private enum Constants {
	static let mgDlConversionFactor:  Decimal = 18
	static let gramsConversionFactor: Decimal = 12
}
