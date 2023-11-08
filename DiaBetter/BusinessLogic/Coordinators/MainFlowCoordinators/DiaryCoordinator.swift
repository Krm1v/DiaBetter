//
//  MeasurementsCoordinator.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.02.2023.
//

import UIKit
import Combine

final class DiaryCoordinator: Coordinator {
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
		let module = DiarySceneBuilder.build(container: container)
		module.transitionPublisher
			.sink { [unowned self] transition in
				switch transition {
				case .edit(let record):
					presentDetailScene(record: record)
				}
			}
			.store(in: &cancellables)
		setRoot(module.viewController)
	}
}

// MARK: - Private extension
private extension DiaryCoordinator {
	func presentDetailScene(record: Record) {
		let module = DiaryDetailSceneBuilder.build(container: container, record: record)
		module.transitionPublisher
			.sink { [unowned self] transition in
				switch transition {
				case .backToDiary:
					pop()
				}
			}
			.store(in: &cancellables)
		push(module.viewController)
	}
}
