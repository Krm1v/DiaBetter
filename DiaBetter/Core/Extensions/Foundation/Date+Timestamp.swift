//
//  Date+Timestamp.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.04.2023.
//

import Foundation

extension Date {
	func convertToInt() -> Int {
		return Int(self.timeIntervalSince1970)
	}
}
