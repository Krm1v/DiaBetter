//
//  ReminderModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 15.06.2023.
//

import Foundation

enum ReminderType: Hashable, Codable {
    case glucose
    case insulin
    case meal
}

struct Reminder: Codable {
    var time: Date
    var reminderType: ReminderType
    var repeats: Bool = true
}

struct Task: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var body: String
    var completed = false
    var reminderEnabled = false
    var reminder: Reminder
}
