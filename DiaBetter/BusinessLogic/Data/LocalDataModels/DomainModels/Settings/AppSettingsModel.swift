//
//  AppSettingsModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.06.2023.
//

import Foundation

struct AppSettingsModel: Codable {
    // MARK: - Properties
	var notifications: NotificationsModel
	var glucoseUnits: SettingsUnits.GlucoseUnitsState
	var carbohydrates: SettingsUnits.CarbsUnits
	var glucoseTarget: GlucoseTarget
    
    // MARK: - Init
	init(
		notifications: NotificationsModel = NotificationsModel(),
		glucoseUnits: SettingsUnits.GlucoseUnitsState = .mmolL,
		carbohydrates: SettingsUnits.CarbsUnits = .breadUnits,
		glucoseTarget: GlucoseTarget = .init(min: 4, max: 11)
	) {
		self.notifications = notifications
		self.glucoseUnits = glucoseUnits
		self.carbohydrates = carbohydrates
		self.glucoseTarget = glucoseTarget
	}
}
