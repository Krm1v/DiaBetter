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
    // MARK: - Properties
    private let networkProvider: NetworkProvider
    private let tokenStorage: TokenStorage
    
    // MARK: - Init
    init(_ networkProvider: NetworkProvider, tokenStorage: TokenStorage) {
        self.networkProvider = networkProvider
        self.tokenStorage = tokenStorage
    }
}

// MARK: - Private extension
extension UserAuthorizationServiceImpl: UserAuthorizationService {
    func userRegister(user: UserRequestModel) -> AnyPublisher<Void, NetworkError> {
        networkProvider.execute(endpoint: .register(user: user))
    }
    
    func loginUser(with credentials: Login) -> AnyPublisher<UserResponseModel, NetworkError> {
        networkProvider.execute(endpoint: .login(credentials: credentials), decodeType: UserResponseModel.self)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self, let tokenValue = response.userToken else {
                    return
                }
                let token = Token(value: tokenValue)
                self.tokenStorage.save(token: token)
            })
            .eraseToAnyPublisher()
    }
}
