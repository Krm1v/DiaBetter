//
//  CreateUserProfileScene.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.02.2023.
//

import UIKit
import Combine

enum CreateUserProfileTransition: Transition {
	case userCreated
	case backToLogin
}

final class CreateUserProfileBuilder {
	static func build(container: AppContainer) -> Module<CreateUserProfileTransition, UIViewController> {
		let viewModel = CreateUserProfileViewModel(userAuthorizationService: container.userAuthorizationService,
												   userService: container.userService)
		let viewController = CreateUserProfileViewController(viewModel: viewModel)
		return Module(viewController: viewController, transitionPublisher: viewModel.transitionPublisher)
	}
}


