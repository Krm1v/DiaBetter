//
//  TimeInterval+String.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 24.04.2023.
//

import Foundation

extension TimeInterval {
	enum DateFormats: String {
		case monthDayYearTime = "MM/dd/yyyy HH:mm:ss"
	}
	
	func convertDateToString(format: DateFormats) -> String {
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone.current
		formatter.dateFormat = format.rawValue
		return formatter.string(from: Date(timeIntervalSince1970: self))
	}
}
