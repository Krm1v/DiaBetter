//
//  CreateUserProfileViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.02.2023.
//

import Foundation
import Combine

final class CreateUserProfileViewModel: BaseViewModel {
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject =  PassthroughSubject<CreateUserProfileTransition, Never>()
	private let userService: UserService
	private var isInputValid: Bool = false
	@Published var email = ""
	@Published var password = ""
	@Published var name = ""
	@Published var country = ""
	@Published var diabetesType = ""
	@Published var fastInsulin = ""
	@Published var longInsulin = ""
	
	//MARK: - Init
	init(userService: UserService) {
		self.userService = userService
		super.init()
	}
	
	//MARK: - Overriden methods
	override func onViewDidLoad() {
		checkValidation()
	}
	
	//MARK: - Public methods
	func backToLogin() {
		transitionSubject.send(.backToLogin)
	}
	
	func checkValidation() {
		$email.combineLatest($password)
			.map { $0.0.validate(with: .emailValidator) && $0.1.validate(with: .passwordValidator) }
			.sink { [unowned self] in isInputValid = $0 }
			.store(in: &cancellables)
	}
	
	func createAccount() {
		let error = NSError(domain: "",
							code: .zero,
							userInfo: [NSLocalizedDescriptionKey: Localization.createAccountValidationErrorDescription])
		isInputValid == true ? createUser() : errorSubject.send(error)
	}
}

//MARK: - Private extension
private extension CreateUserProfileViewModel {
	func createUser() {
		isLoadingSubject.send(true)
		let user = User(name: name,
						email: email,
						password: password,
						diabetesType: diabetesType,
						basalInsulin: longInsulin,
						fastActingInsulin: fastInsulin,
						userProfileImage: nil)
		userService.createUser(user)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				self.isLoadingSubject.send(false)
				switch completion {
				case .finished:
					Logger.info("Finished", shouldLogContext: true)
					self.authorizeUser()
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
	
	func authorizeUser() {
		let credentials = Login(login: email, password: password)
		userService.loginUser(with: credentials)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					Logger.info("Finished", shouldLogContext: true)
					self.transitionSubject.send(.userCreated)
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
}
