//
//  Date+isLastWeek.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 12.09.2023.
//

import Foundation

extension Date {
    func isDateInRange(
        _ date: Date,
        _ component: Calendar.Component,
        _ value: Int
    ) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        guard let startDate = calendar.date(
            byAdding: component,
            value: -value,
            to: currentDate)
        else {
            return false
        }
        let lastDate = currentDate
        return startDate <= date && date <= lastDate
    }
}
