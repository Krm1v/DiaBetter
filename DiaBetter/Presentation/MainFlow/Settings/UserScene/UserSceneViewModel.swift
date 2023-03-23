//
//  UserSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 15.02.2023.
//

import Combine
import Foundation

final class UserSceneViewModel: BaseViewModel {
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<UserSceneTransition, Never>()
	private var userService: UserService
	private var permissionService: PermissionService
	@Published private(set) var userImage: Data?
	@Published var sections: [SectionModel<UserProfileSections, UserSettings>] = []
	@Published var userImageResource: ImageResource?
	
	//MARK: - Init
	init(userService: UserService) {
		self.permissionService = PermissionServiceImpl()
		self.userService = userService
		super.init()
	}
	
	//MARK: - Overriden methods
	override func onViewDidLoad() {
		fetchUser()
	}
	
	func saveUserImageData(from data: Data) {
		userImage = data
	}
	
	//MARK: - Public methods
	func updateDatasource() {
		guard let user = userService.user else { return }
		getImageResource()
		let userHeaderModel = UserHeaderModel(email: user.email ?? "", image: userImageResource)
		let userHeaderSection = SectionModel<UserProfileSections, UserSettings>(section: .header,
																				items: [.header(userHeaderModel)])
		let userSettings = [
			UserDataSettingsModel(title: Localization.name, textFieldValue: user.name ?? ""),
			UserDataSettingsModel(title: Localization.diabetsType, textFieldValue: user.diabetesType ?? ""),
			UserDataSettingsModel(title: Localization.fastActingInsulin, textFieldValue: user.fastActingInsulin ?? ""),
			UserDataSettingsModel(title: Localization.basalInsulin, textFieldValue: user.basalInsulin ?? "")
		]
		var userDataSection = SectionModel<UserProfileSections, UserSettings>(section: .list, items: [])
		userDataSection.items = userSettings.map { .plain($0) }
		sections = [userHeaderSection, userDataSection]
	}
	
	func getImageResource() {
		guard let user = userService.user else { return }
		guard let stringUrl = user.userProfileImage else { return }
		guard let url = URL(string: stringUrl) else { return }
		userImageResource = user.userProfileImage != "" ? .url(url) : .asset(Assets.userImagePlaceholder)
	}
	
	func askForPermissions() {
		permissionService.askForPermissions()
	}
	
	func moveToSettings() {
		permissionService.moveToSettings()
	}
	
	func setupPermissions() {
		permissionService.permissionPublisher
			.sink { type in
				
			}
	}
	
	//MARK: - Network requests
	func fetchUser() {
		isLoadingSubject.send(true)
		guard let token = userService.token else { return }
		guard let id = userService.user?.remoteId else { return }
		userService.fetchUser(token: token, objectId: id)
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .finished:
					debugPrint("User fetched")
				case .failure(let error):
					Logger.error(error.localizedDescription)
				}
			} receiveValue: { [weak self] user in
				guard let self = self else { return }
				self.userService.save(user: User(user))
				self.isLoadingSubject.send(false)
				self.updateDatasource()
			}
			.store(in: &cancellables)
	}
	
	func logoutUser() {
		isLoadingSubject.send(true)
		guard let token = userService.token else { return }
		userService.logoutUser(userToken: token)
			.receive(on: DispatchQueue.main)
			.sink { [weak self ] completion in
				guard let self = self else { return }
				self.isLoadingSubject.send(false)
				switch completion {
				case .finished:
					debugPrint("Success")
				case .failure(let error):
					debugPrint(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { [weak self] response in
				guard let self = self else { return }
				self.userService.clear()
				self.transitionSubject.send(.success)
			}
			.store(in: &cancellables)
	}
	
	func uploadUserProfileImage() {
		guard let token = userService.token else {
			return
		}
		guard let userImage = userImage else {
			return
		}
		let uploadData = MultipartDataItem(data: userImage,
										   attachmentKey: "",
										   fileName: Constants.basicUserProfileImageName)
		userService.uploadUserProfilePhoto(with: token, data: uploadData)
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .finished:
					debugPrint("Success")
				case .failure(let error):
					Logger.error(error.localizedDescription)
				}
			} receiveValue: { [weak self] response in
				guard let self = self else { return }
				guard var user = self.userService.user else { return }
				user.userProfileImage = response.fileURL
				self.updateUser(user)
			}
			.store(in: &cancellables)
	}
	
	func deleteUserProfilePhoto() {
		guard let token = userService.token else { return }
		userService.deletePhoto(userToken: token,
								filename: Constants.basicUserProfileImageName + Constants.basicImageFormat)
			.sink { [weak self] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					debugPrint("Photo was deleted from backend")
					guard var user = self.userService.user else { return }
					user.userProfileImage = ""
					self.updateUser(user)
				case .failure(let error):
					Logger.error(error.localizedDescription)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
	
	func updateUser(_ user: User) {
		isLoadingSubject.send(true)
		guard let token = userService.token else { return }
		let updatedUser = UserUpdateRequestModel(basalInsulin: user.basalInsulin, diabetesType: user.diabetesType, fastActingInsulin: user.fastActingInsulin, name: user.name, userProfileImage: user.userProfileImage)
		debugPrint(updatedUser)
		userService.updateUser(user: updatedUser, objectId: user.remoteId ?? "", token: token)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				self.isLoadingSubject.send(false)
				switch completion {
				case .finished:
					debugPrint("User updated")
					self.updateDatasource()
				case .failure(let error):
					Logger.error(error.localizedDescription)
				}
			} receiveValue: { [weak self] user in
				guard let self = self else { return }
				self.userService.save(user: User(user))
			}
			.store(in: &cancellables)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let basicUserProfileImageName = "userProfileImage"
	static let basicImageFormat = ".jpeg"
}
