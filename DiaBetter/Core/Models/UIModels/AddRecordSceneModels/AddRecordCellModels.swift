//
//  AddRecordCellModels.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 27.04.2023.
//

import Foundation

struct DatePickerCellModel: Hashable {
	let title: String
}

struct GlucoseLevelOrMealCellModel: Hashable {
	enum GlucoseOrMealCellState {
		case glucose
		case meal
	}

	let title: String
	let textfieldValue: String
	let unitsTitle: String
	let currentField: GlucoseOrMealCellState
}

struct InsulinCellModel: Hashable {
	let fastInsulinTitle: String
	let basalInsulinTitle: String
	let fastInsulinTextfieldValue: String
	let basalInsulinTextFieldValue: String
	let unitsTitleForFastInsulin: String
	let unitsTitleForBasalInsulin: String
}

struct NoteCellModel: Hashable {
	let title: String
	let textViewValue: String
}
