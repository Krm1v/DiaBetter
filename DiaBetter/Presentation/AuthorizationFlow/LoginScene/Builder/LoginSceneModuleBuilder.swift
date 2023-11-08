//
//  LoginSceneModuleBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 24.02.2023.
//

import UIKit
import Combine

enum LoginTransition: Transition {
    case loggedIn
    case signUp
    case restorePassword
}

final class LoginModuleBuilder {
    static func build(container: AppContainer) -> Module<LoginTransition, UIViewController> {
        let viewModel = LoginSceneViewModel(userService: container.userService)
        let viewController = LoginSceneViewController(viewModel: viewModel)
        return Module(
            viewController: viewController,
            transitionPublisher: viewModel.transitionPublisher)
    }
}
