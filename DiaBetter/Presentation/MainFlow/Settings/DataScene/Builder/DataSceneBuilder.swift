//
//  DataSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.07.2023.
//

import UIKit

enum DataSceneTransitions: Transition {}

final class DataSceneBuilder {
	static func build(container: AppContainer) -> Module<DataSceneTransitions, UIViewController> {
		let viewModel = DataSceneViewModel()
		let viewController = DataSceneViewConroller(viewModel: viewModel)
		return Module(viewController: viewController, transitionPublisher: viewModel.transitionPublisher)
	}
}
