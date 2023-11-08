//
//  Date+isSameDay.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 01.05.2023.
//

import Foundation

extension Date {
    func isSameDay(
        as date: Date,
        timeZone: TimeZone = .current
    ) -> Bool {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = timeZone
        return calendar.isDate(self, inSameDayAs: date)
    }
}
