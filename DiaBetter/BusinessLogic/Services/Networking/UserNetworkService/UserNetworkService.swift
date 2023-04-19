//
//  UserAPIService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 22.02.2023.
//

import Foundation
import Combine

protocol UserNetworkService {
	func updateUser(user: UserUpdateRequestModel, objectId: String) -> AnyPublisher<UserResponseModel, NetworkError>
	func deleteUser(with id: String) -> AnyPublisher<Void, NetworkError>
	func restorePassword(for email: String) -> AnyPublisher<Void, NetworkError>
	func logoutUser() -> AnyPublisher<Void, NetworkError>
	func deletePhoto(filename: String) -> AnyPublisher<Void, NetworkError>
	func uploadUserProfilePhoto(data: MultipartDataItem) -> AnyPublisher<UserProfilePictureResponse, NetworkError>
	func fetchUser(withId id: String) -> AnyPublisher<UserResponseModel, NetworkError>
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
	func updateUser(user: UserUpdateRequestModel, objectId: String) -> AnyPublisher<UserResponseModel, NetworkError> {
		networkProvider.execute(endpoint: .update(user: user, id: objectId), decodeType: UserResponseModel.self)
	}
	
	func deleteUser(with id: String) -> AnyPublisher<Void, NetworkError> {
		networkProvider.execute(endpoint: .delete(id: id))
	}
	
	func restorePassword(for email: String) -> AnyPublisher<Void, NetworkError> {
		networkProvider.execute(endpoint: .restorePassword(userEmail: email))
	}
	
	func logoutUser() -> AnyPublisher<Void, NetworkError> {
		networkProvider.execute(endpoint: .logout)
	}
	
	func deletePhoto(filename: String) -> AnyPublisher<Void, NetworkError> {
		networkProvider.execute(endpoint: .deletePhoto(filename: filename))
	}
	
	func uploadUserProfilePhoto(data: MultipartDataItem) -> AnyPublisher<UserProfilePictureResponse, NetworkError> {
		networkProvider.execute(endpoint: .uploadPhoto(data: data), decodeType: UserProfilePictureResponse.self)
	}
	
	func fetchUser(withId id: String) -> AnyPublisher<UserResponseModel, NetworkError> {
		networkProvider.execute(endpoint: .fetchUser(id: id), decodeType: UserResponseModel.self)
	}
}
