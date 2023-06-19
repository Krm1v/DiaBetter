//
//  UserService.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import Foundation
import Combine

enum UserServiceError: Error {
	case missingToken
	case missingUserId
	case invalidPassword
}

protocol UserService {
	var isAuthorized: Bool { get }
	var user: User? { get }
	var userPublisher: AnyPublisher<User?, Never> { get }
	
	func clear()
	func save(user: User)
	func loginUser(with credentials: Login) -> AnyPublisher<User, Error>
	func uploadUserProfilePhoto(data: MultipartDataItem) -> AnyPublisher<UserProfilePictureDomainModel, Error>
	func logoutUser() -> AnyPublisher<Void, Error>
	func deletePhoto(filename: String) -> AnyPublisher<Void, Error>
	func updateUser(user: User) -> AnyPublisher<User, Error>
	func fetchUser(id: String) -> AnyPublisher<User, Error>
	func createUser(_ user: User) -> AnyPublisher<Void, Error>
	func restorePassword(_ email: String) -> AnyPublisher<Void, Error>
}

final class UserServiceImpl {
	//MARK: - Properties
	private let userDefaults: UserDefaultsManager
	private let dataConverter: DataConverter
	private let userNetworkService: UserNetworkService
	private let userAuthorizationService: UserAuthorizationService
	private let tokenStorage: TokenStorage
	private let userSubject = CurrentValueSubject<User?, Never>(nil)
	private(set) lazy var userPublisher = userSubject.eraseToAnyPublisher()
	private var cancellables = Set<AnyCancellable>()
	
	//MARK: - Init
	init(userNetworkService: UserNetworkService,
		 userAuthorizationService: UserAuthorizationService,
		 tokenStorage: TokenStorage) {
		self.userNetworkService = userNetworkService
		self.userAuthorizationService = userAuthorizationService
		self.userDefaults = UserDefaultsManagerImpl<User>()
		self.dataConverter = DataConverterImpl()
		self.tokenStorage = tokenStorage
		guard let dataUser: Data = fetchFromDefaults(for: .dataUser) else { return }
		let user = deseriallize(from: dataUser)
		userSubject.send(user)
	}
	
	//MARK: - Public methods
	func save(user: User) {
		let dataUser = seriallize(user: user)
		saveToDefaults(value: dataUser, for: .dataUser)
		userSubject.send(user)
	}
	
	func clear() {
		tokenStorage.clear()
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
	func loginUser(with credentials: Login) -> AnyPublisher<User, Error> {
		return userAuthorizationService.loginUser(with: credentials)
			.mapError { $0 as Error }
			.map { User($0) }
			.handleEvents(receiveOutput: { [weak self] user in
				guard let self = self else { return }
				self.save(user: user)
			})
			.eraseToAnyPublisher()
	}
	
	func uploadUserProfilePhoto(data: MultipartDataItem) -> AnyPublisher<UserProfilePictureDomainModel, Error> {
		return userNetworkService.uploadUserProfilePhoto(data: data)
			.mapError { $0 as Error }
			.map { response in
				return UserProfilePictureDomainModel(response)
			}
			.handleEvents(receiveOutput: { [weak self] response in
				guard var user = self?.user else { return }
				user.userProfileImage = response.fileURL
				self?.save(user: user)
			})
			.eraseToAnyPublisher()
	}
	
	func logoutUser() -> AnyPublisher<Void, Error> {
		return userNetworkService.logoutUser()
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func deletePhoto(filename: String) -> AnyPublisher<Void, Error> {
		return userNetworkService.deletePhoto(filename: filename)
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func updateUser(user: User) -> AnyPublisher<User, Error> {
		let userUpdateRequest = UserUpdateRequestModel(basalInsulin: user.basalInsulin,
													   diabetesType: user.diabetesType,
													   fastActingInsulin: user.fastActingInsulin,
													   name: user.name,
													   userProfileImage: user.userProfileImage)
		guard let userId = user.remoteId else {
			return Fail(error: UserServiceError.missingUserId)
				.eraseToAnyPublisher()
		}
		return userNetworkService.updateUser(user: userUpdateRequest, objectId: userId)
			.mapError { $0 as Error }
			.map(User.init)
			.handleEvents(receiveOutput: { [weak self] response in
				guard let self = self else { return }
				self.save(user: response)
			})
			.eraseToAnyPublisher()
	}

	func fetchUser(id: String) -> AnyPublisher<User, Error> {
		return userNetworkService.fetchUser(withId: id)
			.mapError { $0 as Error }
			.map(User.init)
			.handleEvents(receiveOutput: { [weak self] response in
				guard let self = self else { return }
				self.save(user: response)
			})
			.eraseToAnyPublisher()
	}
	
	func createUser(_ user: User) -> AnyPublisher<Void, Error> {
		let user = UserRequestModel(basalInsulin: user.basalInsulin ?? "",
									diabetesType: user.diabetesType ?? "",
									password: user.password ?? "",
									email: user.email ?? "",
									fastActingInsulin: user.fastActingInsulin ?? "",
									name: user.name ?? "",
									userProfileImage: nil)
		return userAuthorizationService.userRegister(user: user)
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func restorePassword(_ email: String) -> AnyPublisher<Void, Error> {
		return userNetworkService.restorePassword(for: email)
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
}

//MARK: - Extension UserService
extension UserServiceImpl: UserService {
	var user: User? {
		userSubject.value
	}
	
	var isAuthorized: Bool {
		tokenStorage.token != nil
	}
}
