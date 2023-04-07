//
//  SceneDelegate.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 24.10.2021.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	//MARK: - Properties
	var window: UIWindow?
	var cancellables = Set<AnyCancellable>()
	var appCoordinator: AppCoordinator!
	var appContainer: AppContainer!
	
	//MARK: - Methods
	func scene(_ scene: UIScene,
			   willConnectTo session: UISceneSession,
			   options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		self.window = UIWindow(windowScene: windowScene)
		self.appContainer = AppContainerImpl()
		self.appCoordinator = AppCoordinator(window: window!,
											 container: appContainer)
		self.appCoordinator?.start()
	}
}

