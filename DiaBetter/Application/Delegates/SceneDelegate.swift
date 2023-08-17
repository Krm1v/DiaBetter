//
//  SceneDelegate.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 24.10.2021.
//

import UIKit
import SwiftUI
import Combine

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	// MARK: - Properties
	var window: UIWindow?
	var appCoordinator: AppCoordinator?
	var appContainer: AppContainer?

	// MARK: - Methods
	func scene(
		_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
			guard let windowScene = (scene as? UIWindowScene) else {
				return
			}
			self.window = UIWindow(windowScene: windowScene)
			self.appContainer = AppContainerImpl()
			guard
				let window = window,
				let appContainer = appContainer
			else {
				return
			}
			self.appCoordinator = AppCoordinator(window: window,
												 container: appContainer)
			UIBarButtonItem.appearance().setTitleTextAttributes(
				[
					.font: FontFamily.Montserrat.regular.font(size: 15)
				],
				for: .normal)
			self.appCoordinator?.start()
		}
}
