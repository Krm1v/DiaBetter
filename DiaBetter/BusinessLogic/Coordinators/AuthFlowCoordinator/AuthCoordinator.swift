//
//  AuthCoordinator.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import UIKit
import Combine

final class AuthCoordinator: Coordinator {
	//MARK: - Properties
	var childCoordinators: [Coordinator] = []
	var navigationController: UINavigationController
	let container: AppContainer
	private(set) lazy var didFinishPublisher = didFinishSubject.eraseToAnyPublisher()
	private let didFinishSubject = PassthroughSubject<Void, Never>()
	private var cancellables = Set<AnyCancellable>()
	
	//MARK: - Init
	init(navigationController: UINavigationController, container: AppContainer) {
		self.navigationController = navigationController
		self.container = container
	}
	
	//MARK: - Public methods
	func start() {
		startLoginScene()
	}
}

//MARK: - Private extension
private extension AuthCoordinator {
	func startLoginScene() {
		let module = LoginModuleBuilder.build(container: container)
		module.transitionPublisher
			.sink { [unowned self] transition in
				switch transition {
				case .loggedIn: didFinishSubject.send()
				case .signUp: signUp()
				case .restorePassword: restorePassword()
				}
			}
			.store(in: &cancellables)
		setRoot([module.viewController])
	}
	
	func signUp() {
		let module = CreateUserProfileBuilder.build(container: container)
		module.transitionPublisher
			.sink { [unowned self] transition in
				switch transition {
				case .userCreated: didFinishSubject.send()
				case .backToLogin: pop()
				}
			}
			.store(in: &cancellables)
		push(module.viewController)
	}
	
	func restorePassword() {
		let module = ResetPasswordSceneBuilder.build(container: container)
		module.transitionPublisher
			.sink { [unowned self] transition in
				switch transition {
				case .backToLogin: pop()
				}
			}
			.store(in: &cancellables)
		push(module.viewController)
	}
}
