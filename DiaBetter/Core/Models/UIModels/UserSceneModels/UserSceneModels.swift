//
//  UserSceneModels.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 29.05.2023.
//

import Foundation

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
