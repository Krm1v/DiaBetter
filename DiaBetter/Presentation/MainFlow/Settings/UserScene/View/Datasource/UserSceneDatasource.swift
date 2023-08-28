//
//  UserSceneDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.03.2023.
//

import Foundation

// MARK: - Sections
enum UserProfileSections: Int, Hashable {
	case header
	case list
	case logout
}

// MARK: - Items
enum UserSettings: Hashable {
	case header(UserHeaderModel)
	case plainWithTextfield(UserDataSettingsModel)
	case plainWithLabel(UserDataMenuSettingsModel)
	case plainWithButton(LogoutButtonModel)
}

enum UserParameters: Hashable {
	case diabetesType
	case fastInsulin
	case longInsulin

	var items: [UserParametersProtocol] {
		switch self {
		case .diabetesType:
			return UserTreatmentSettings.DiabetesType.allCases
		case .fastInsulin:
			return UserTreatmentSettings.FastInsulines.allCases
		case .longInsulin:
			return UserTreatmentSettings.LongInsulines.allCases
		}
	}
}
