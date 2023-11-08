//
//  String+DecimalValue.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.03.2023.
//

import Foundation

extension String {
	static let numberFormatter = NumberFormatter()
	var decimalValue: Decimal? {
		String.numberFormatter.decimalSeparator = "."
		if let result =  String.numberFormatter.number(from: self) {
			return result.decimalValue
		} else {
			String.numberFormatter.decimalSeparator = ","
			if let result = String.numberFormatter.number(from: self) {
				return result.decimalValue
			}
		}
		return nil
	}
}
