//
//  AddRecordSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import UIKit
import Combine

enum AddRecordSceneTransition: Transition {
    case success
}

final class AddRecordSceneBuilder {
    static func build(container: AppContainer) -> Module<AddRecordSceneTransition, UIViewController> {
        let viewModel = AddRecordSceneViewModel(
            recordsService: container.recordsService,
            userService: container.userService,
            settingsService: container.settingsService,
            unitsConvertManager: container.unitsConvertManager)
        
        let viewController = AddRecordSceneViewController(viewModel: viewModel)
        return Module(
            viewController: viewController,
            transitionPublisher: viewModel.transitionPiblisher)
    }
}
