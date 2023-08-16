//
//  CreditsSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.06.2023.
//

import UIKit

enum CreditsSceneTransitions: Transition {}

final class CreditsSceneBuilder {
	static func build(container: AppContainer) -> Module<CreditsSceneTransitions, UIViewController> {
		let viewModel = CreditsSceneViewModel()
		let viewController = CreditsSceneViewController(viewModel: viewModel)
		return Module(viewController: viewController, transitionPublisher: viewModel.transitionPublisher)
	}
}
