//
//  UserService.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import Foundation
import KeychainAccess
import Combine

protocol UserService {
	var isAuthorized: Bool { get }
	var token: String? { get }
	var user: User? { get }
	var userPublisher: AnyPublisher<User?, Never> { get }
	
	func clear()
	func save(user: User)
	func save(token: String)
	func uploadUserProfilePhoto(with userToken: String, data: MultipartDataItem) -> AnyPublisher<UserProfilePictureResponse, NetworkError>
	func logoutUser(userToken: String) -> AnyPublisher<Void, NetworkError>
	func deletePhoto(userToken: String, filename: String) -> AnyPublisher<Void, NetworkError>
	func updateUser(user: UserUpdateRequestModel, objectId: String, token: String) -> AnyPublisher<UserResponseModel, NetworkError>
	func fetchUser(token: String, objectId id: String) -> AnyPublisher<UserResponseModel, NetworkError>
}

final class UserServiceImpl {
	//MARK: - Properties
	private let keychain: Keychain
	private let userDefaults: UserDefaultsManager
	private let dataConverter: DataConverter
	private let configuration: AppConfiguration
	private let userNetworkService: UserNetworkService
	private let userSubject = CurrentValueSubject<User?, Never>(nil)
	private(set) lazy var userPublisher = userSubject.eraseToAnyPublisher()
	private var cancellables = Set<AnyCancellable>()
	
	//MARK: - Init
	init(configuration: AppConfiguration, userNetworkService: UserNetworkService) {
		self.configuration = configuration
		self.userNetworkService = userNetworkService
		self.keychain = Keychain(service: configuration.bundleId)
		self.userDefaults = UserDefaultsManagerImpl<User>()
		self.dataConverter = DataConverterImpl()
		guard let dataUser: Data = fetchFromDefaults(for: .dataUser) else { return }
		userSubject.value = deseriallize(from: dataUser)
		userSubject.send(user)
	}
	
	//MARK: - Public methods
	//MARK: - Keychain and UserDefaults
	func save(token: String) {
		keychain[Keys.token] = token
	}
	
	func save(user: User) {
		let dataUser = seriallize(user: user)
		saveToDefaults(value: dataUser, for: .dataUser)
		userSubject.value = user
		userSubject.send(user)
	}
	
	func clear() {
		keychain[Keys.token] = nil
		deleteFromDefaults(for: .dataUser)
		userSubject.send(user)
	}
	
	func saveToDefaults<T>(value: T, for key: UserDefaultsKeys) {
		userDefaults.save(value, for: key)
	}
	
	func fetchFromDefaults<T>(for key: UserDefaultsKeys) -> T? {
		let value: T? = userDefaults.fetch(for: key)
		return value
	}
	
	func deleteFromDefaults(for key: UserDefaultsKeys) {
		userDefaults.delete(key)
	}
	
	//MARK: - Converting methods
	func seriallize(user: User) -> Data? {
		let dataUser = dataConverter.seriallizeToData(object: user)
		return dataUser
	}
	
	func deseriallize(from data: Data) -> User? {
		let user: User? = dataConverter.deseriallizeFromData(data: data)
		return user
	}
	
	//MARK: - Network requests
	func uploadUserProfilePhoto(with userToken: String, data: MultipartDataItem) -> AnyPublisher<UserProfilePictureResponse, NetworkError> {
		userNetworkService.uploadUserProfilePhoto(with: userToken, data: data)
	}
	
	func logoutUser(userToken: String) -> AnyPublisher<Void, NetworkError> {
		userNetworkService.logoutUser(userToken: userToken)
	}
	
	func deletePhoto(userToken: String, filename: String) -> AnyPublisher<Void, NetworkError> {
		userNetworkService.deletePhoto(userToken: userToken, filename: filename)
	}
	
	func updateUser(user: UserUpdateRequestModel, objectId: String, token: String) -> AnyPublisher<UserResponseModel, NetworkError> {
		userNetworkService.updateUser(user: user, objectId: objectId, token: token)
	}
	
	func fetchUser(token: String, objectId id: String) -> AnyPublisher<UserResponseModel, NetworkError> {
		userNetworkService.fetchUser(userToken: token, withId: id)
	}
}

//MARK: - Extension UserService
extension UserServiceImpl: UserService {
	var user: User? {
		userSubject.value
	}
	
	var isAuthorized: Bool {
		keychain[Keys.token] != nil
	}
	
	var token: String? {
		keychain[Keys.token]
	}
	
	var email: String? {
		keychain[Keys.email]
	}
	
	var name: String? {
		keychain[Keys.name]
	}
	
	var userId: String? {
		keychain[Keys.userId]
	}
}

extension UserServiceImpl {
	private enum Keys: CaseIterable {
		static let token = "secure_token_key"
		static let email = "secure_email_key"
		static let name = "secure_name_key"
		static let userId = "secure_userId_key"
	}
}
