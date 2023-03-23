//
//  UserSceneDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.03.2023.
//

import UIKit

struct UserHeaderModel: Hashable {
	let email: String
	let image: ImageResource?
}

struct UserDataSettingsModel: Hashable {
	let title: String
	let textFieldValue: String
}

enum UserProfileSections: Int, Hashable {
	case header
	case list
}

enum UserSettings: Hashable {
	case header(UserHeaderModel)
	case plain(UserDataSettingsModel)
}
