//
//  HomeSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import UIKit

enum HomeSceneTransition: Transition {
	case toAddRecordScene
}

final class HomeSceneModuleBuilder {
	static func build(container: AppContainer) -> Module<HomeSceneTransition, UIViewController> {
		let viewModel = HomeSceneViewModel(recordService: container.recordsService, userService: container.userService)
		let viewController = HomeSceneViewController(viewModel: viewModel)
		return Module(viewController: viewController, transitionPublisher: viewModel.transitionPublisher)
	}
}
