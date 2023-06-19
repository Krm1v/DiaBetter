//
//  NotificationsDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import Foundation

enum ReminderDayTime: Hashable {
	case morning
	case day
	case evening
	
	var emoji: String {
		switch self {
		case .morning: return "☕️"
		case .day: 	   return "☀️"
		case .evening: return "🛌"
		}
	}
	
	var title: String {
		switch self {
		case .morning: return Localization.morning
		case .day: 	   return Localization.day
		case .evening: return Localization.evening
		}
	}
}

enum ReminderValueType: Hashable {
	case glucose
	case insulin
	case meal
}



enum NotificationsSections: Int, Hashable, CaseIterable {
	case enabler
	case main
	
	var title: String {
		switch self {
		case .enabler: return Localization.enableOrDisableNotifications
		case .main:    return Localization.chooseReminders
		}
	}
}

enum NotificationItems: Hashable {
	case notificationsEnabler(SwitcherCellModel)
	case reminderSwitch(type: ReminderValueType, model: SwitcherCellModel)
	case reminder(type: ReminderValueType, model: ReminderCellModel)
}
