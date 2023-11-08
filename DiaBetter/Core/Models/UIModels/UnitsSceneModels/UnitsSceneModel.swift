//
//  UnitsSceneModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 30.06.2023.
//

import Foundation

struct UnitsSectionModel: Hashable {
    let id = UUID()
    let title: String
}

struct GlucoseUnitsCellModel: Hashable {
    let title: String
    let currentUnit: SettingsUnits.GlucoseUnitsState
}

struct CarbsUnitsCellModel: Hashable {
    let title: String
    let currentUnit: SettingsUnits.CarbsUnits
}

struct TargetGlucoseCellModel: Hashable {
    let title: String
    let value: String
    let stepperValue: Double
    let type: MinMaxGlucoseTarget
}
