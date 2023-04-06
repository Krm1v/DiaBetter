//
//  DiabetesTypes.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 05.04.2023.
//

import Foundation

enum DiabetesType: String, CaseIterable, SettingsMenuDatasourceProtocol {
	case type1
	case type2
	case gestational
	case prediabetes
	case other
	
	var title: String {
		switch self {
		case .type1:
			return "Type 1"
		case .type2:
			return "Type 2"
		case .gestational:
			return "Gestational Diabetes"
		case .prediabetes:
			return "Prediabetes"
		case .other:
			return "Other"
		}
	}
}
