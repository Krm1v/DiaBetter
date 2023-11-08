//
//  SettingsSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.03.2023.
//

import UIKit
import Combine

enum SettingsTransition: Transition {
    case userScene
    case notificationsScene
    case unitsScene
    case dataScene
    case creditsScene
}

final class SettingsSceneBuilder {
    static func build(container: AppContainer) -> Module<SettingsTransition, UIViewController> {
        let viewModel = SettingsSceneViewModel()
        let viewController = SettingsSceneViewController(viewModel: viewModel)
        return Module(
            viewController: viewController,
            transitionPublisher: viewModel.transitionPublisher)
    }
}
