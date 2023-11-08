//
//  AppSettingsModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.06.2023.
//

import Foundation

struct GlucoseTarget: Codable {
	var min: Decimal
	var max: Decimal
}

struct NotificationsModel: Codable {
	var areNotificationsEnabled: Bool
	var glucoseReminder: ReminderModel
	var insulinReminder: ReminderModel
	var mealReminder: ReminderModel

	// MARK: - Init
	init(
		areNotificationsEnabled: Bool = false,
		glucoseReminder: ReminderModel = .init(type: .glucose, isOn: false, time: .init()),
		insulinReminder: ReminderModel = .init(type: .insulin, isOn: false, time: .init()),
		mealReminder: ReminderModel = .init(type: .meal, isOn: false, time: .init())
	) {
		self.areNotificationsEnabled = areNotificationsEnabled
		self.glucoseReminder = glucoseReminder
		self.insulinReminder = insulinReminder
		self.mealReminder = mealReminder
	}
}

struct AppSettingsModel: Codable {
	var notifications: NotificationsModel
	var glucoseUnits: SettingsUnits.GlucoseUnitsState
	var carbohydrates: SettingsUnits.CarbsUnits
	var glucoseTarget: GlucoseTarget

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
