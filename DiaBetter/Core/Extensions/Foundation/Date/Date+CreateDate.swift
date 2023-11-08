//
//  Date+CreateDate.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 14.06.2023.
//

import Foundation

func createDateWithHoursAndMinutes(hours: Int, minutes: Int) -> Date {
    var calendar = Calendar.current
    let currentDate = Date()
    calendar.timeZone = .current
    let currentComponents = calendar.dateComponents(
        [.year, .month, .day],
        from: currentDate)
    
    var dateComponents = DateComponents()
    dateComponents.year = currentComponents.year
    dateComponents.month = currentComponents.month
    dateComponents.day = currentComponents.day
    dateComponents.hour = hours
    dateComponents.minute = minutes
    
    return calendar.date(from: dateComponents) ?? Date()
}
