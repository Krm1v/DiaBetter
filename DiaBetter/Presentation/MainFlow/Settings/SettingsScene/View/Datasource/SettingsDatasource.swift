//
//  SettingsSceneModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import Foundation

enum SettingsGroup: Int, CaseIterable, Hashable {
    case general
    case about
    
    var title: String {
        switch self {
        case .general:
            return Localization.general
        case .about:
            return Localization.about
        }
    }
    
    var group: [Settings] {
        switch self {
        case .general:
            return [.user, .notifications, .data, .units]
        case .about:
            return [.credits, .sendFeedback]
        }
    }
}

enum Settings: String, Hashable {
    case user
    case notifications
    case data
    case units
    case credits
    case sendFeedback
    
    var title: String {
        switch self {
        case .user:
            return Localization.user
        case .notifications:
            return Localization.notifications
        case .data:
            return Localization.data
        case .units:
            return Localization.units
        case .credits:
            return Localization.credits
        case .sendFeedback:
            return Localization.sendFeedback
        }
    }
}
