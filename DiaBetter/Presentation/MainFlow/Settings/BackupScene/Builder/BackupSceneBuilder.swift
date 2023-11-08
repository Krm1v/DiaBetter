//
//  BackupSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.07.2023.
//

import UIKit

enum BackupSceneTransitions: Transition {}

final class BackupSceneBuilder {
	static func build(container: AppContainer) -> Module<BackupSceneTransitions, UIViewController> {
		let viewModel = BackupSceneViewModel(
			recordService: container.recordsService,
			userService: container.userService,
			settingsService: container.settingsService,
			unitsConvertManager: container.unitsConvertManager)
        
		let viewController = BackupSceneViewController(viewModel: viewModel)
		return Module(
            viewController: viewController,
            transitionPublisher: viewModel.transitionPublisher)
	}
}
