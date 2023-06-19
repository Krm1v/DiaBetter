//
//  Decimal+toDouble.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.05.2023.
//

import Foundation

extension Decimal {
	func toDouble() -> Double {
		Double(truncating: self as NSNumber)
	}
}
