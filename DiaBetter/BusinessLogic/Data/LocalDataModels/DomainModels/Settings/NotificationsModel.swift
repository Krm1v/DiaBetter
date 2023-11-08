//
//  NotificationsModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.09.2023.
//

import Foundation

struct NotificationsModel: Codable {
    // MARK: - Properties
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
