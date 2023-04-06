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
	private let userAuthorizationService: UserAuthorizationService
	private let userService: UserService
	@Published var email = ""
	@Published var password = ""
	@Published var name = ""
	@Published var country = ""
	@Published var diabetesType = ""
	@Published var fastInsulin = ""
	@Published var longInsulin = ""
	
	//MARK: - Init
	init(userAuthorizationService: UserAuthorizationService, userService: UserService) {
		self.userAuthorizationService = userAuthorizationService
		self.userService = userService
		super.init()
	}
	
	//MARK: - Public methods
	func backToLogin() {
		transitionSubject.send(.backToLogin)
	}
	
	func createUser() {
		isLoadingSubject.send(true)
		let user = UserRequestModel(basalInsulin: longInsulin,
									diabetesType: diabetesType,
									password: password,
									email: email,
									fastActingInsulin: fastInsulin,
									name: name,
									userProfileImage: nil)
		userAuthorizationService.userRegister(user: user)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				self.isLoadingSubject.send(false)
				switch completion {
				case .finished:
					self.authorizeUser()
				case .failure(let error):
					debugPrint(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
}

//MARK: - Private extension
private extension CreateUserProfileViewModel {
	func authorizeUser() {
		let credentials = Login(login: email, password: password)
		userAuthorizationService.loginUser(with: credentials)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				switch completion {
				case .finished:
					self?.transitionSubject.send(.userCreated)
				case .failure(let error):
					debugPrint(error.localizedDescription)
					self?.errorSubject.send(error)
				}
			} receiveValue: { [weak self] user in
				guard let self = self else { return }
				self.userService.save(user: User(user))
				guard let token = user.userToken else { return }
				self.userService.save(token: token)
			}
			.store(in: &cancellables)
	}
}
