//
//  Decimal+String.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.04.2023.
//

import Foundation

extension Decimal {
	func convertToString() -> String {
		let numberFormatter = NumberFormatter()
		numberFormatter.minimumFractionDigits = 1
		numberFormatter.maximumFractionDigits = 1
		numberFormatter.decimalSeparator = "."

		return numberFormatter.string(from: self as NSDecimalNumber) ?? ""
	}
}
