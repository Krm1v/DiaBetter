//
//  LoginSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 24.02.2023.
//

import Foundation
import Combine

final class LoginSceneViewModel: BaseViewModel {
	// MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject =  PassthroughSubject<LoginTransition, Never>()
	private let userService: UserService
	private var isInputValid: Bool = false
	@Published var email = ""
	@Published var password = ""

	// MARK: - Init
	init(userService: UserService) {
		self.userService = userService
		super.init()
	}

	// MARK: - Overriden methods
	override func onViewDidLoad() {
		checkValidation()
	}

	// MARK: - Public methods
	func checkValidation() {
		$email.combineLatest($password)
			.map { !$0.0.isEmpty && !$0.1.isEmpty }
			.sink { [unowned self] in isInputValid = $0 }
			.store(in: &cancellables)
	}

	func login() {
		let error = NSError(domain: "",
							code: .zero,
							userInfo: [NSLocalizedDescriptionKey: Localization.loginValidationErrorDescription])
		isInputValid ? loginUser() : errorSubject.send(error)
	}

	func moveToCreateAccountScene() {
		transitionSubject.send(.signUp)
	}

	func moveToResetPasswordScene() {
		transitionSubject.send(.restorePassword)
	}
}

// MARK: - Private extension
private extension LoginSceneViewModel {
	func loginUser() {
		let creds = Login(login: email, password: password)
		isLoadingSubject.send(true)
		userService.loginUser(with: creds)
			.subscribe(on: DispatchQueue.global(qos: .userInitiated))
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					Logger.info("Success")
					self.transitionSubject.send(.loggedIn)
					self.isLoadingSubject.send(false)
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.isLoadingSubject.send(false)
					self.errorSubject.send(error)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
}
