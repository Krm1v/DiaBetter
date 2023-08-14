//
//  ResetPasswordViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 02.03.2023.
//

import Foundation
import Combine

final class ResetPasswordSceneViewModel: BaseViewModel {
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<ResetPasswordTransition, Never>()
	private let userService: UserService
	@Published var email = ""
	
	//MARK: - Init
	init(userService: UserService) {
		self.userService = userService
		super.init()
	}
	
	//MARK: - Public methods
	func resetPassword() {
		isLoadingSubject.send(true)
		userService.restorePassword(email)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self ] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					NetworkLogger.info("Finished", shouldLogContext: true)
					self.isLoadingSubject.send(false)
					self.infoSubject.send((Localization.resetPasswordTitle,
										   Localization.resetPasswordMessage))
				case .failure(let error):
					NetworkLogger.error(error.localizedDescription, shouldLogContext: true)
					self.errorSubject.send(error)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
	
	func moveBackToLoginScene() {
		transitionSubject.send(.backToLogin)
	}
}
