//
//  SplashScreenBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 29.08.2023.
//

import UIKit

enum SplashScreenTransitions: Transition {
	case didFinish(status: UserAuthorizationStatus)
}

final class SplashScreenBuilder {
	static func build(container: AppContainer) -> Module<SplashScreenTransitions, UIViewController> {
        let viewModel = SplashScreenViewModel(userService: container.userService)
		let viewController = SplashScreenViewController(viewModel: viewModel)
		return Module(viewController: viewController, transitionPublisher: viewModel.transitionPublisher)
	}
}
