//
//  UserSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 15.02.2023.
//

import UIKit
import Combine

enum UserSceneTransition: Transition {
	case success
}

final class UserSceneModuleBuilder {
	static func build(container: AppContainer) -> Module<UserSceneTransition, UIViewController> {
		let viewModel = UserSceneViewModel(userService: container.userService)
		let viewController = UserSceneViewController(viewModel: viewModel)
		return Module(viewController: viewController, transitionPublisher: viewModel.transitionPublisher)
	}
}
