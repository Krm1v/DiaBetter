//
//  SplashScreenViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 29.08.2023.
//

import Foundation
import Combine

final class SplashScreenViewModel: BaseViewModel {
	// MARK: - Properties
	private let userService: UserService

	// MARK: - Transitions
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<SplashScreenTransitions, Never>()

	// MARK: - Init
    init(userService: UserService) {
		self.userService = userService
	}

	// MARK: - Overriden methods
	override func onViewDidLoad() {
		checkAuthorization()
	}
}

// MARK: - Private extension
private extension SplashScreenViewModel {
	func checkAuthorization() {
		switch userService.isAuthorized {
		case true:
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.transitionSubject.send(.didFinish(status: .authorized))
			}
		case false:
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				self.transitionSubject.send(.didFinish(status: .unauthorized))
			}
		}
	}
}
