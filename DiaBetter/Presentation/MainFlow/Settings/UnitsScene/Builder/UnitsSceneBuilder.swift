//
//  UnitsSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.06.2023.
//

import UIKit

enum UnitsSceneTransitions: Transition {}

final class UnitsSceneBuilder {
    static func build(container: AppContainer) -> Module<UnitsSceneTransitions, UIViewController> {
        let viewModel = UnitsSceneViewModel(
            settingsService: container.settingsService,
            unitsConvertManager: container.unitsConvertManager)
        
        let viewController = UnitsSceneViewController(viewModel: viewModel)
        return Module(
            viewController: viewController,
            transitionPublisher: viewModel.transitionPublisher)
    }
}
