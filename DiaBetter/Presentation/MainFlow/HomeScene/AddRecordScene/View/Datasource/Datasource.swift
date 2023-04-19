//
//  Datasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.04.2023.
//

import Foundation

struct DatePickerCellModel: Hashable {
	let title: String
}

struct GlucoseLevelOrMealCellModel: Hashable {
	let title: String
	let parameterTitle: String
	let textfieldValue: String
	let unitsTitle: String
}

struct InsulinCellModel: Hashable {
	let title: String
	let parameterTitleForFastInsulin: String
	let parameterTitleForBasalInsulin: String
	let fastInsulinTextfieldValue: String
	let basalInsulinTextFieldValue: String
	let unitsTitleForFastInsulin: String
	let unitsTitleForBasalInsulin: String
}

struct NoteCellModel: Hashable {
	let title: String
	let textViewValue: String
}

enum RecordParameterSections: Int, Hashable {
	case date
	case main
	case unsulin
	case note
	case buttons
}

enum RecordParameterItems: Hashable {
	case date(DatePickerCellModel)
	case glucoseLevelOrMeal(GlucoseLevelOrMealCellModel)
	case insulin(InsulinCellModel)
	case note(NoteCellModel)
	case buttons
}
