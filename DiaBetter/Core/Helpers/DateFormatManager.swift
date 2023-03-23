//
//  DateConverter.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.03.2023.
//

import Foundation

enum DateFormats: String {
	case monthDayYearTime = "MM/dd/yyyy HH:mm:ss"
}

protocol DateFormatManager {
	func convertDateToString(fromTimeStamp timestamp: TimeInterval, format: DateFormats) -> String
}

final class DateFormatManagerImpl {
	//MARK: - Propertirs
	private let formatter: DateFormatter
	
	//MARK: - Init
	init(formatter: DateFormatter = DateFormatter()) {
		self.formatter = formatter
	}
}

//MARK: - Extension DateFormatManager
extension DateFormatManagerImpl: DateFormatManager {
	func convertDateToString(fromTimeStamp timestamp: TimeInterval, format: DateFormats) -> String {
		formatter.timeZone = TimeZone.current
		formatter.dateFormat = format.rawValue
		return formatter.string(from: Date(timeIntervalSince1970: timestamp))
	}
}

