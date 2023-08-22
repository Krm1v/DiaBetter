//
//  MainTabBar.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.08.2023.
//

import UIKit

final class MainTabBar: UITabBar {
	override func layoutSubviews() {
		super.layoutSubviews()
		setupTabBarAppearance()
	}
}

// MARK: - Private extension
private extension MainTabBar {
	func setupTabBarAppearance() {
		let tabBarAppearance = UITabBarAppearance()
		tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
		tabBarAppearance.stackedLayoutAppearance.normal.iconColor = Colors.customDarkenPink.color
		tabBarAppearance.stackedLayoutAppearance.selected.iconColor = Colors.customPink.color
		tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: Colors.customDarkenPink.color]
		tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: Colors.customPink.color]
		self.standardAppearance = tabBarAppearance
		if #available(iOS 15.0, *) {
			self.scrollEdgeAppearance = tabBarAppearance
		}
		self.layer.masksToBounds = true
		self.isTranslucent = true
		self.barStyle = .black
	}
}
