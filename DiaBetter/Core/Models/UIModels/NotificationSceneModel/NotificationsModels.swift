//
//  NotificationsModels.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 15.06.2023.
//

import Foundation

struct ReminderModel: Codable {
	let type: ReminderType
	var isOn: Bool
	var time: ReminderTimeModel
}

struct ReminderTimeModel: Codable {
	var morning: Date
	var day: Date
	var evening: Date

	init(
		morning: Date = createDateWithHoursAndMinutes(hours: 8, minutes: 00),
		day: Date = createDateWithHoursAndMinutes(hours: 14, minutes: 00),
		evening: Date = createDateWithHoursAndMinutes(hours: 20, minutes: 00)
	) {
		self.morning = morning
		self.day = day
		self.evening = evening
	}
}

struct SwitcherCellModel: Hashable {
	let title: String
	let isOn: Bool
}

struct ReminderCellModel: Hashable {
	let dayTime: ReminderDayTime
	let date: Date?

	var title: String {
		"\(dayTime.emoji) \(dayTime.title)"
	}
}
