//
//  UserAuthorizationService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 02.03.2023.
//

import Foundation
import Combine

protocol UserAuthorizationService {
	func userRegister(user: UserRequestModel) -> AnyPublisher<Void, NetworkError>
	func loginUser(with credentials: Login) -> AnyPublisher<UserResponseModel, NetworkError>
}

final class UserAuthorizationServiceImpl<NetworkProvider: NetworkServiceProvider> where NetworkProvider.EndpointType == UserAuthorizationEndpoint {
	//MARK: - Properties
	private let networkProvider: NetworkProvider
	
	//MARK: - Init
	init(_ networkProvider: NetworkProvider) {
		self.networkProvider = networkProvider
	}
}

//MARK: - Private extension
extension UserAuthorizationServiceImpl: UserAuthorizationService {
	func userRegister(user: UserRequestModel) -> AnyPublisher<Void, NetworkError> {
		networkProvider.execute(endpoint: .register(user: user))
	}
	
	func loginUser(with credentials: Login) -> AnyPublisher<UserResponseModel, NetworkError> {
		networkProvider.execute(endpoint: .login(credentials: credentials), decodeType: UserResponseModel.self)
	}
}
