//
//  UIApplication+OpenSettings.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 14.04.2023.
//

import UIKit

extension UIApplication {
	func openSettings() {
		guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
			assertionFailure("Not able to open App privacy settings")
			return
		}
		UIApplication.shared.open(url)
	}
}
