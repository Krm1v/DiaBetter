//
//  UnitsConverterManager.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 30.08.2023.
//

import Foundation

protocol UnitsConvertManager: AnyObject {
	func convertRecordUnits(records: [Record]) -> [Record]
	func convertRecordUnits(record: Record) -> Record
}

final class UnitsConvertManagerImpl {
	// MARK: - Properties
	private var settingsService: SettingsService

	// MARK: - Init
	init(settingsService: SettingsService) {
		self.settingsService = settingsService
	}
}

// MARK: - Extension UnitsConverterManager
extension UnitsConvertManagerImpl: UnitsConvertManager {
	func convertRecordUnits(records: [Record]) -> [Record] {
		let convertedGlucoseRecords = convertGlucoseUnits(records: records)
		let convertedRecords = convertMealUnits(records: convertedGlucoseRecords)
		return convertedRecords
	}

	func convertRecordUnits(record: Record) -> Record {
		let convertedGlucoseRecord = convertGlucoseUnits(record: record)
		let convertedRecord = convertMealUnits(record: convertedGlucoseRecord)
		return convertedRecord
	}
}

// MARK: - Private extension
private extension UnitsConvertManagerImpl {
	func convertGlucoseUnits(records: [Record]) -> [Record] {
		var convertedRecords = [Record]()
		switch settingsService.settings.glucoseUnits {
		case .mmolL:
			convertedRecords = records
			return convertedRecords
		case .mgDl:
			convertedRecords = records.map { record in
				var record = record
				guard let glucoseValue = record.glucoseLevel else {
					return record
				}
				record.glucoseLevel = glucoseValue * Constants.mgDlConversionFactor
				return record
			}
			return convertedRecords
		}
	}

	func convertMealUnits(records: [Record]) -> [Record] {
		var convertedRecords = [Record]()
		switch settingsService.settings.carbohydrates {
		case .grams:
			convertedRecords = records.map({ record in
				var record = record
				guard let mealValue = record.meal else {
					return record
				}
				record.meal = mealValue * Constants.gramsConversionFactor
				return record
			})
			return convertedRecords
		case .breadUnits:
			convertedRecords = records
			return convertedRecords
		}
	}

	func convertGlucoseUnits(record: Record) -> Record {
		var convertedRecord = record
		switch settingsService.settings.glucoseUnits {
		case .mmolL:
			return convertedRecord
		case .mgDl:
			guard let glucoseValue = convertedRecord.glucoseLevel else {
				return record
			}
			convertedRecord.glucoseLevel = glucoseValue * Constants.mgDlConversionFactor
			return convertedRecord
		}
	}

	func convertMealUnits(record: Record) -> Record {
		var convertedRecord = record
		switch settingsService.settings.carbohydrates {
		case .breadUnits:
			return convertedRecord
		case .grams:
			guard let mealValue = convertedRecord.meal else {
				return record
			}
			convertedRecord.meal = mealValue * Constants.gramsConversionFactor
			return convertedRecord
		}
	}
}

// MARK: - Constants
private enum Constants {
	static let mgDlConversionFactor:  Decimal = 18
	static let gramsConversionFactor: Decimal = 12
}
