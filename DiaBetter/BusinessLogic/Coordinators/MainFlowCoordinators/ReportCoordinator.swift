//
//  ReportCoordinator.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.03.2023.
//
import UIKit
import Combine

final class ReportCoordinator: Coordinator {
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
		let module = ReportSceneBuilder.build(container: container)
		module.transitionPublisher
			.sink { [unowned self] transition in
				
			}
			.store(in: &cancellables)
		setRoot(module.viewController)
	}
}
