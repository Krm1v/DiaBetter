//
//  DiaryDetailSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.06.2023.
//

import UIKit

enum DiaryDetailSceneTransition: Transition {
    case backToDiary
}

final class DiaryDetailSceneBuilder {
    static func build(container: AppContainer, record: Record) -> Module<DiaryDetailSceneTransition, UIViewController> {
        let viewModel = DiaryDetailSceneViewModel(
            record: record,
            recordService: container.recordsService,
            settingsService: container.settingsService,
            unitsConvertManager: container.unitsConvertManager)
        
        let viewController = DiaryDetailSceneViewController(viewModel: viewModel)
        return Module(
            viewController: viewController,
            transitionPublisher: viewModel.transitionPublisher)
    }
}
