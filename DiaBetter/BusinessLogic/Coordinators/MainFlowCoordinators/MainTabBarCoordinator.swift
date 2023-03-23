//
//  MainTabBarCoordinator.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import UIKit
import Combine

final class MainTabBarCoordinator: Coordinator {
	//MARK: - Properties
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	private(set) lazy var didFinishPublisher = didFinishSubject.eraseToAnyPublisher()
	private let didFinishSubject = PassthroughSubject<Void, Never>()
	private var cancellables = Set<AnyCancellable>()
	private let container: AppContainer
	
	//MARK: - Init
	init(navigationController: UINavigationController, container: AppContainer) {
		self.navigationController = navigationController
		self.container = container
	}
	
	//MARK: - Public methods
	func start() {
		setupHomeCoordinator()
		setupReportCoordinator()
		setupMeasurementsCoordinator()
		setupSettingsCoordinator()
		let controllers = childCoordinators
			.compactMap { $0.navigationController }
		let module = MainTabBarModuleBuilder.build(viewControllers: controllers)
		setRoot(module.viewController)
	}
}

//MARK: - Private extension
private extension MainTabBarCoordinator {
	func setupHomeCoordinator() {
		let navigationController = UINavigationController()
		navigationController.tabBarItem = .init(title: "Home",
												image: UIImage(systemName: ImageConstants.house),
												selectedImage: UIImage(systemName: ImageConstants.houseFilled))
		let coordinator = HomeCoordinator(navigationController: navigationController, container: container)
		childCoordinators.append(coordinator)
		coordinator.didFinishPublisher
			.sink { [unowned self] in
				childCoordinators.forEach { removeChild(coordinator: $0) }
				didFinishSubject.send()
			}
			.store(in: &cancellables)
		coordinator.start()
	}
	
	func setupMeasurementsCoordinator() {
		let navigationController = UINavigationController()
		navigationController.tabBarItem = .init(title: "Diary",
												image: UIImage(systemName: ImageConstants.book),
												selectedImage: UIImage(systemName: ImageConstants.bookFilled))
		let coordinator = MeasurementsCoordinator(navigationController: navigationController, container: container)
		childCoordinators.append(coordinator)
		coordinator.didFinishPublisher
			.sink { [unowned self] in
				childCoordinators.forEach { removeChild(coordinator: $0) }
				didFinishSubject.send()
			}
			.store(in: &cancellables)
		coordinator.start()
	}
	
	func setupReportCoordinator() {
		let navigationController = UINavigationController()
		navigationController.tabBarItem = .init(title: "Report",
												image: UIImage(systemName: "list.bullet.clipboard"),
												selectedImage: UIImage(systemName: "list.bullet.clipboard.fill"))
		let coordinator = ReportCoordinator(navigationController: navigationController, container: container)
		childCoordinators.append(coordinator)
		coordinator.didFinishPublisher
			.sink { [unowned self] in
				childCoordinators.forEach { removeChild(coordinator: $0) }
				didFinishSubject.send()
			}
			.store(in: &cancellables)
		coordinator.start()
	}
	
	func setupSettingsCoordinator() {
		let navigationController = UINavigationController()
		navigationController.tabBarItem = .init(title: "Settings",
												image: UIImage(systemName: ImageConstants.gear),
												selectedImage: UIImage(systemName: ImageConstants.gearFilled))
		let coordinator = SettingsCoordinator(navigationController: navigationController, container: container)
		childCoordinators.append(coordinator)
		coordinator.didFinishPublisher
			.sink { [unowned self] in
				childCoordinators.forEach { removeChild(coordinator: $0) }
				didFinishSubject.send()
			}
			.store(in: &cancellables)
		coordinator.start()
	}
}

//MARK: - ImageConstants
fileprivate enum ImageConstants {
	static let house = "house"
	static let houseFilled = "house.fill"
	static let book = "book.closed"
	static let bookFilled = "book.closed.fill"
	static let gear = "gear.circle"
	static let gearFilled = "gear.circle.fill"
}
