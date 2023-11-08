//
//  UserSceneModels.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 29.05.2023.
//

import Foundation

protocol UserSceneDataModelProtocol { }

struct UserHeaderModel: Hashable {
    let email: String
    let image: ImageResourceType?
}

struct UserDataSettingsModel: Hashable {
    let title: String
    let textFieldValue: String
}

struct UserDataMenuSettingsModel: Hashable, UserSceneDataModelProtocol {
    let rowTitle: String
    var labelValue: String
    let source: UserParameters
}
