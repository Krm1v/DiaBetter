//
//  Date+Timestamp.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.04.2023.
//

import Foundation

extension Date {
	enum DateFormats: String {
		case monthDayYearTime = "MM/dd/yyyy HH:mm:ss"
	}
	
	func convertDateToString(fromTimeStamp timestamp: TimeInterval, format: DateFormats) -> String {
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone.current
		formatter.dateFormat = format.rawValue
		return formatter.string(from: Date(timeIntervalSince1970: timestamp))
	}
}
