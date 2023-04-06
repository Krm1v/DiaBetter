//
//  UserSceneDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.03.2023.
//

import UIKit

protocol UserDataModel {}

struct UserHeaderModel: Hashable {
	let email: String
	let image: ImageResource?
}

struct UserDataSettingsModel: Hashable, UserDataModel {
	let title: String
	let textFieldValue: String
}

struct UserDataMenuSettingsModel: Hashable, UserDataModel {
	let title: String
	var labelValue: String
	let source: SettingsMenuDatasource
}

enum SettingsMenuDatasource: Hashable {
	case diabetesType
	case fastInsulines
	case longInsulines
	
	var type: [SettingsMenuDatasourceProtocol] {
		switch self {
		case .diabetesType:
			return DiabetesType.allCases
		case .fastInsulines:
			return FastInsulines.allCases
		case .longInsulines:
			return LongInsulines.allCases
		}
	}
}

enum UserProfileSections: Int, Hashable {
	case header
	case list
}

enum UserSettings: Hashable, UserDataModel {
	case header(UserHeaderModel)
	case plainWithTextfield(UserDataSettingsModel)
	case plainWithLabel(UserDataMenuSettingsModel)
}
