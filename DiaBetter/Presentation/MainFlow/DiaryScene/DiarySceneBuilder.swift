//
//  MeasurementsSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.02.2023.
//

import UIKit
import Combine

enum DiarySceneTransition: Transition {
	case success
}

final class DiarySceneBuilder {
	static func build(container: AppContainer) -> Module<DiarySceneTransition, UIViewController> {
		let viewModel = DiarySceneViewModel()
		let viewController = DiarySceneViewController(viewModel: viewModel)
		return Module(viewController: viewController, transitionPublisher: viewModel.transitionPublisher)
	}
}
