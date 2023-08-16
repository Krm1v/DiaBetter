//
//  AppCoordinator.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import UIKit
import Combine

final class AppCoordinator: Coordinator {
	//MARK: - Properties
	var window: UIWindow
	var navigationController: UINavigationController
	let container: AppContainer
	var childCoordinators: [Coordinator] = []
	private(set) lazy var didFinishPublisher = didFinishSubject.eraseToAnyPublisher()
	private let didFinishSubject = PassthroughSubject<Void, Never>()
	private var cancellables = Set<AnyCancellable>()
	
	//MARK: - Init
	init(window: UIWindow,
		 container: AppContainer,
		 navigationController: UINavigationController = UINavigationController()
	) {
		self.window = window
		self.container = container
		self.navigationController = navigationController
	}
	
	//MARK: - Public methods
	func start() {
		self.window.rootViewController = navigationController
		self.window.makeKeyAndVisible()
		container.userService.isAuthorized ? mainFlow() : authFlow()
	}
}

//MARK: - Private extension
private extension AppCoordinator {
	func authFlow() {
		let authCoordinator = AuthCoordinator(navigationController: navigationController,
											  container: container)
		childCoordinators.append(authCoordinator)
		authCoordinator.didFinishPublisher
			.sink { [unowned self] in
				mainFlow()
				removeChild(coordinator: authCoordinator)
			}
			.store(in: &cancellables)
		authCoordinator.start()
	}
	
	func mainFlow() {
		let mainCoordinator = MainTabBarCoordinator(navigationController: navigationController,
													container: container)
		childCoordinators.append(mainCoordinator)
		mainCoordinator.didFinishPublisher
			.sink { [unowned self] in
				authFlow()
				removeChild(coordinator: mainCoordinator)
			}
			.store(in: &cancellables)
		mainCoordinator.start()
	}
}
