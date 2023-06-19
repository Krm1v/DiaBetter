//
//  MealUnits.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.04.2023.
//

import Foundation

enum MealUnits: String, Hashable {
	case breadUnits
	case grams
	
	var description: String {
		switch self {
		case .breadUnits: return "BU"
		case .grams: return "g."
		}
	}
}
