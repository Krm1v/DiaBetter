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
	private let userNetworkService: UserNetworkService
	@Published var email = ""
	
	//MARK: - Init
	init(userNetworkService: UserNetworkService) {
		self.userNetworkService = userNetworkService
		super.init()
	}
	
	//MARK: - Public methods
	override func onViewDidLoad() {
		super.onViewDidLoad()
	}
	
	func resetPassword() {
		isLoadingSubject.send(true)
		userNetworkService.restorePassword(for: email)
			.receive(on: DispatchQueue.main)
			.sink { [weak self ] completion in
				guard let self = self else { return }
				self.isLoadingSubject.send(false)
				switch completion {
				case .finished:
					self.infoSubject.send((Constants.alertTitle, Constants.alertInfo))
				case .failure(let error):
					debugPrint(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { response in
				debugPrint(response)
			}
			.store(in: &cancellables)
	}
	
	func moveBackToLoginScene() {
		transitionSubject.send(.backToLogin)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let alertTitle = "Password successfully reset"
	static let alertInfo = "Your new password was sent to your email address."
}
