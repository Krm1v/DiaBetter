//
//  LogoutButtonModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 28.08.2023.
//

import Foundation

enum UserProfileButtonType {
    case logout
    case deleteAccount
}

struct UserProfileButtonModel: Hashable, UserSceneDataModelProtocol {
    let buttonTitle: String
    let buttonType: UserProfileButtonType
}
