//
//  Date+String.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 27.04.2023.
//

import Foundation

extension Date {
	func stringRepresentation(
		format: DateFormats,
		timeZone: TimeZone = .current
	) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format.rawValue
		dateFormatter.timeZone = timeZone
		dateFormatter.locale = .current
		return dateFormatter.string(from: self)
	}
}
