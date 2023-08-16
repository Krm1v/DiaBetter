//
//  MainTabBarCoordinator.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import UIKit
import Combine

private enum TabBarItems {
	case home
	case diary
	case report
	case settings

	var title: String {
		switch self {
		case .home: 	return Localization.home
		case .diary: 	return Localization.diary
		case .report: 	return Localization.report
		case .settings: return Localization.settings
		}
	}

	var image: UIImage? {
		switch self {
		case .home: 	return UIImage(systemName: "house")
		case .diary: 	return UIImage(systemName: "book.closed")
		case .report: 	return UIImage(systemName: "drop")
		case .settings: return UIImage(systemName: "gear.circle")
		}
	}

	var selectedImage: UIImage? {
		switch self {
		case .home: 	return UIImage(systemName: "house.fill")
		case .diary: 	return UIImage(systemName: "book.closed.fill")
		case .report: 	return UIImage(systemName: "drop.fill")
		case .settings: return UIImage(systemName: "gear.circle.fill")
		}
	}

	var tabBarItem: UITabBarItem {
		return UITabBarItem(title: title,
							image: image,
							selectedImage: selectedImage)
	}
}

final class MainTabBarCoordinator: Coordinator {
	// MARK: - Properties
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	private(set) lazy var didFinishPublisher = didFinishSubject.eraseToAnyPublisher()
	private let didFinishSubject = PassthroughSubject<Void, Never>()
	private var cancellables = Set<AnyCancellable>()
	private let container: AppContainer

	// MARK: - Init
	init(
		navigationController: UINavigationController,
		container: AppContainer
	) {
		self.navigationController = navigationController
		self.container = container
	}

	// MARK: - Public methods
	func start() {
		setupHomeCoordinator()
		setupReportCoordinator()
		setupDiaryCoordinator()
		setupSettingsCoordinator()
		let controllers = childCoordinators
			.compactMap { $0.navigationController }
		let module = MainTabBarModuleBuilder.build(viewControllers: controllers)
		setRoot(module.viewController)
	}
}

// MARK: - Private extension
private extension MainTabBarCoordinator {
	func setupHomeCoordinator() {
		let navigationController = UINavigationController()
		navigationController.tabBarItem = TabBarItems.home.tabBarItem
		let coordinator = HomeCoordinator(
			navigationController: navigationController,
			container: container)

		childCoordinators.append(coordinator)
		coordinator.didFinishPublisher
			.sink { [unowned self] in
				childCoordinators.forEach { removeChild(coordinator: $0) }
				didFinishSubject.send()
			}
			.store(in: &cancellables)
		coordinator.start()
	}

	func setupDiaryCoordinator() {
		let navigationController = UINavigationController()
		navigationController.tabBarItem = TabBarItems.diary.tabBarItem
		let coordinator = DiaryCoordinator(
			navigationController: navigationController,
			container: container)

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
		navigationController.tabBarItem = TabBarItems.report.tabBarItem
		let coordinator = ReportCoordinator(
			navigationController: navigationController,
			container: container)

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
		navigationController.tabBarItem = TabBarItems.settings.tabBarItem
		let coordinator = SettingsCoordinator(
			navigationController: navigationController,
			container: container)
		
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
