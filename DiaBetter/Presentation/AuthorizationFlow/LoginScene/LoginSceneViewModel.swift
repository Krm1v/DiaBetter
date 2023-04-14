//
//  LoginSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 24.02.2023.
//

import Foundation
import Combine
import KeychainAccess

final class LoginSceneViewModel: BaseViewModel {
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject =  PassthroughSubject<LoginTransition, Never>()
	private let userAuthorizationService: UserAuthorizationService
	private let userNetworkService: UserNetworkService
	private let userService: UserService
	@Published var email = ""
	@Published var password = ""
	
	//MARK: - Init
	init(userAuthorizationService: UserAuthorizationService,
		 userService: UserService,
		 userNetworkService: UserNetworkService) {
		self.userAuthorizationService = userAuthorizationService
		self.userService = userService
		self.userNetworkService = userNetworkService
		super.init()
	}
	
	//MARK: - Methods
	override func onViewDidLoad() {
		//		$email
		//			.map { $0.count > 5 }
		//			.sink { [unowned self] in isEmailValid = $0 }
		//			.store(in: &cancellables)
		//
		//		$password
		//			.map { $0.count > 5 }
		//			.sink { [unowned self] in isPasswordValid = $0 }
		//			.store(in: &cancellables)
		//
		//		$isEmailValid.combineLatest($isPasswordValid)
		//			.map { $0 && $1 }
		//			.sink { [unowned self] in isInputValid = $0 }
		//			.store(in: &cancellables)
		
	}
	
	func loginUser() {
		isLoadingSubject.send(true)
		let credentials = Login(login: email,
								password: password)
		debugPrint(credentials)
		userAuthorizationService.loginUser(with: credentials)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				self.isLoadingSubject.send(false)
				switch completion {
				case .finished:
					debugPrint("Success")
				case .failure(let error):
					debugPrint(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { [weak self] fetchedUser in
				guard let self = self else { return }
				debugPrint(fetchedUser.userToken)
				self.userService.save(user: User(fetchedUser))
				self.transitionSubject.send(.loggedIn)
			}
			.store(in: &cancellables)
	}
	
	func moveToCreateAccountScene() {
		transitionSubject.send(.signUp)
	}
	
	func moveToResetPasswordScene() {
		transitionSubject.send(.restorePassword)
	}
}
