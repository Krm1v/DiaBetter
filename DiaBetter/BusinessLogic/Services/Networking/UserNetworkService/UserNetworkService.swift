//
//  UserAPIService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 22.02.2023.
//

import Foundation
import Combine

protocol UserNetworkService {
	func updateUser(user: UserUpdateRequestModel, objectId: String, token: Token) -> AnyPublisher<UserResponseModel, NetworkError>
	func deleteUser(with objectId: String) -> AnyPublisher<Void, NetworkError>
	func restorePassword(for email: String) -> AnyPublisher<Void, NetworkError>
	func logoutUser(userToken: Token) -> AnyPublisher<Void, NetworkError>
	func deletePhoto(userToken: Token, filename: String) -> AnyPublisher<Void, NetworkError>
	func uploadUserProfilePhoto(with userToken: Token, data: MultipartDataItem) -> AnyPublisher<UserProfilePictureResponse, NetworkError>
	func fetchUser(userToken: Token, withId id: String) -> AnyPublisher<UserResponseModel, NetworkError>
}

final class UserNetworkServiceImpl<NetworkProvider: NetworkServiceProvider> where NetworkProvider.EndpointType == UserEndpoint {
	//MARK: - Properties
	private let networkProvider: NetworkProvider
	
	//MARK: - Init
	init(_ networkProvider: NetworkProvider) {
		self.networkProvider = networkProvider
	}
}

//MARK: - Private extension
extension UserNetworkServiceImpl: UserNetworkService {
	func updateUser(user: UserUpdateRequestModel, objectId: String, token: Token) -> AnyPublisher<UserResponseModel, NetworkError> {
		networkProvider.execute(endpoint: .update(user: user, objectID: objectId, token: token.value), decodeType: UserResponseModel.self)
	}
	
	func deleteUser(with objectId: String) -> AnyPublisher<Void, NetworkError> {
		networkProvider.execute(endpoint: .delete(objectID: objectId))
	}
	
	func restorePassword(for email: String) -> AnyPublisher<Void, NetworkError> {
		networkProvider.execute(endpoint: .restorePassword(userEmail: email))
	}
	
	func logoutUser(userToken: Token) -> AnyPublisher<Void, NetworkError> {
		networkProvider.execute(endpoint: .logout(token: userToken.value))
	}
	
	func deletePhoto(userToken: Token, filename: String) -> AnyPublisher<Void, NetworkError> {
		networkProvider.execute(endpoint: .deletePhoto(token: userToken.value, filename: filename))
	}
	
	func uploadUserProfilePhoto(with userToken: Token, data: MultipartDataItem) -> AnyPublisher<UserProfilePictureResponse, NetworkError> {
		networkProvider.execute(endpoint: .uploadPhoto(token: userToken.value, data: data), decodeType: UserProfilePictureResponse.self)
	}
	
	func fetchUser(userToken: Token, withId id: String) -> AnyPublisher<UserResponseModel, NetworkError> {
		networkProvider.execute(endpoint: .fetchUser(token: userToken.value, objectId: id), decodeType: UserResponseModel.self)
	}
}
