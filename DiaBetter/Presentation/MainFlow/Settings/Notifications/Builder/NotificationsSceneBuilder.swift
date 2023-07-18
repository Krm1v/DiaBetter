//
//  NotificationsSceneBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import UIKit

enum NotificationsSceneTransitions: Transition {}

final class NotificationsSceneBuilder {
	static func build(container: AppContainer) -> Module<NotificationsSceneTransitions, UIViewController> {
		let viewModel = NotificationsSceneViewModel(permissionService: container.permissionService, notificationManager: container.userNotificationManager, appSettingsService: container.appSettingsService)
		let viewController = NotificationsSceneViewController(viewModel: viewModel)
		return Module(viewController: viewController, transitionPublisher: viewModel.transitionPublisher)
	}
}
