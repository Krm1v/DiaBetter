//
//  Datasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.04.2023.
//

import Foundation

enum RecordParameterSections: Int, Hashable {
    case date
    case main
    case insulin
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
