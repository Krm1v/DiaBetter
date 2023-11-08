//
//  UserCoordinator.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.02.2023.
//

import UIKit
import Combine

final class HomeCoordinator: Coordinator {
	// MARK: - Properties
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	private let didFinishSubject = PassthroughSubject<Void, Never>()
	private(set) lazy var didFinishPublisher = didFinishSubject.eraseToAnyPublisher()
	private let container: AppContainer
	private var cancellables = Set<AnyCancellable>()

	// MARK: - Init
	init(navigationController: UINavigationController, container: AppContainer) {
		self.navigationController = navigationController
		self.container = container
	}

	// MARK: - Public methods
	func start() {
		let module = HomeSceneModuleBuilder.build(container: container)
		module.transitionPublisher
			.sink { [unowned self] transition in
				switch transition {
				case .toAddRecordScene:
					presentAddRecordScene()
				}
			}
			.store(in: &cancellables)
		setRoot(module.viewController)
	}
}

// MARK: - Private extension
private extension HomeCoordinator {
	func presentAddRecordScene() {
		let module = AddRecordSceneBuilder.build(container: container)
		module.transitionPublisher
			.sink { [unowned self] transition in
				switch transition {
				case .success:
					dismiss()
				}
			}
			.store(in: &cancellables)
		let navigationController = UINavigationController(rootViewController: module.viewController)
		presentScene(navigationController)
	}
}
