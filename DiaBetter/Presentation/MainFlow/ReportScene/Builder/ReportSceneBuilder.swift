//
//  ReportSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.03.2023.
//

import UIKit

enum ReportTransition: Transition {}

final class ReportSceneBuilder {
	static func build(container: AppContainer) -> Module<ReportTransition, UIViewController> {
        let viewModel = ReportViewModel(
            recordsService: container.recordsService,
            userService: container.userService,
            settingsService: container.settingsService,
            unitsConvertManager: container.unitsConvertManager)
        let viewController = ReportViewController(viewModel: viewModel)
		return Module(viewController: viewController, transitionPublisher: viewModel.transitionPublisher)
	}
}
