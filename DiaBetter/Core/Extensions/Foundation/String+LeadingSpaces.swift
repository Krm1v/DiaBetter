//
//  String+LeadingSpaces.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.04.2023.
//

import Foundation

extension String {
	func removingLeadingSpaces() -> String {
		guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
			return self
		}
		return String(self[index...])
	}
}
