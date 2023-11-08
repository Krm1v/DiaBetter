//
//  GlucoseLevelUnits.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.04.2023.
//

import Foundation

enum GlucoseLevelUnits: String, Hashable {
	case mmolL
	case mgDl

	var description: String {
		switch self {
		case .mmolL: return "mmol/L"
		case .mgDl: return "mg/dL"
		}
	}
}
