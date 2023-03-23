//
//  SettingsCoordinator.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.03.2023.
//

import UIKit
import Combine

final class SettingsCoordinator: Coordinator {
	//MARK: - Properties
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	private let didFinishSubject = PassthroughSubject<Void, Never>()
	private(set) lazy var didFinishPublisher = didFinishSubject.eraseToAnyPublisher()
	private let container: AppContainer
	private var cancellables = Set<AnyCancellable>()
	
	//MARK: - Init
	init(navigationController: UINavigationController, container: AppContainer) {
		self.navigationController = navigationController
		self.container = container
	}
	
	//MARK: - Public methods
	func start() {
		let module = SettingsSceneBuilder.build(container: container)
		module.transitionPublisher
			.sink { [unowned self] transition in
				switch transition {
				case .userScene:
					openUserSettings()
				}
			}
			.store(in: &cancellables)
		setRoot(module.viewController)
	}
}

//MARK: - Private extension
private extension SettingsCoordinator {
	func openUserSettings() {
		let module = UserSceneModuleBuilder.build(container: container)
		module.transitionPublisher
			.sink { [unowned self] transition in
				switch transition {
				case .success:
					didFinishSubject.send()
				}
			}
			.store(in: &cancellables)
		push(module.viewController)
	}
}
