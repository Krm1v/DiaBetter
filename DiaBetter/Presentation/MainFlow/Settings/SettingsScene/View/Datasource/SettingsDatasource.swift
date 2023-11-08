//
//  SettingsSceneModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import Foundation

enum SettingsGroup: Int, CaseIterable, Hashable {
	case general
	case customization
	case about
	case empty

	var title: String {
		switch self {
		case .general:
			return Localization.general
		case .customization:
			return Localization.customization
		case .about:
			return Localization.about
		case .empty:
			return ""
		}
	}

	var group: [Settings] {
		switch self {
		case .general:
			return [.user, .notifications, .data, .units]
		case .customization:
			return [.appIcon]
		case .about:
			return [.credits, .rateTheApp, .sendFeedback]
		case .empty:
			return [.showOnboarding]
		}
	}
}

enum Settings: String, Hashable {
	case user
	case notifications
	case data
	case units
	case appIcon
	case credits
	case rateTheApp
	case sendFeedback
	case showOnboarding

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
		case .appIcon:
			return Localization.appIcon
		case .credits:
			return Localization.credits
		case .rateTheApp:
			return Localization.rateTheApp
		case .sendFeedback:
			return Localization.sendFeedback
		case .showOnboarding:
			return Localization.showOnboarding
		}
	}
}
