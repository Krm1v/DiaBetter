//
//  UserSceneDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.03.2023.
//

import UIKit
import Combine

protocol UserDataModel {}

enum SettingsMenuDatasource: Hashable {
	case diabetesType
	case fastInsulines
	case longInsulines
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
