//
//  ResetPasswordScene.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 02.03.2023.
//

import UIKit
import Combine

enum ResetPasswordTransition: Transition {
	case backToLogin
}

final class ResetPasswordSceneBuilder {
	static func build(container: AppContainer) -> Module<ResetPasswordTransition, UIViewController> {
		let viewModel = ResetPasswordSceneViewModel(userService: container.userService)
		let viewController = ResetPasswordSceneViewController(viewModel: viewModel)
		return Module(
            viewController: viewController,
            transitionPublisher: viewModel.transitionPublisher)
	}
}
