//
//  Date+Timestamp.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.04.2023.
//

import Foundation

extension Date {
	func toDouble() -> Double {
		return Double(self.timeIntervalSince1970)
	}
}
