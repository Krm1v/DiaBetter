//
//  UserSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 15.02.2023.
//

import Combine
import Foundation
import Kingfisher

final class UserSceneViewModel: BaseViewModel {
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private(set) var permissionService: PermissionService
	private let transitionSubject = PassthroughSubject<UserSceneTransition, Never>()
	private let userService: UserService
	
	//MARK: - Published properties
	@Published private(set) var userImage: Data?
	@Published private var userImageResource: ImageResource?
	@Published var sections: [SectionModel<UserProfileSections, UserSettings>] = []
	@Published var userName = ""
	@Published var userDiabetesType = ""
	@Published var userFastInsulin = ""
	@Published var userBasalInsulin = ""
	
	//MARK: - Init
	init(userService: UserService) {
		self.permissionService = PermissionServiceImpl()
		self.userService = userService
		super.init()
	}
	
	override func onViewDidLoad() {
		fetchUser()
		showPlaceholderDatasource()
	}
	
	override func onViewWillDisappear() {
		guard let user = updatedUser() else { return }
		updateUser(user)
		isLoadingSubject.send(false)
	}
	
	//MARK: - Public methods
	//MARK: - Datasource methods
	func updateDatasource() {
		getImageResource()
		guard let user = userService.user else { return }
		let userHeaderModel = UserHeaderModel(email: user.email ?? "",
											  image: userImageResource)
		let userHeaderSection = SectionModel<UserProfileSections, UserSettings>(
			section: .header,
			items: [
				.header(userHeaderModel)
			]
		)
		let userName = UserDataSettingsModel(title: Localization.name,
											 textFieldValue: user.name ?? "")
		let userSettings = [
			UserDataMenuSettingsModel(title: Localization.diabetsType,
									  labelValue: user.diabetesType ?? "",
									  source: .diabetesType),
			UserDataMenuSettingsModel(title: Localization.fastActingInsulin,
									  labelValue: user.fastActingInsulin ?? "",
									  source: .fastInsulines),
			UserDataMenuSettingsModel(title: Localization.basalInsulin,
									  labelValue: user.basalInsulin ?? "",
									  source: .longInsulines)
		]
		var userDataSection = SectionModel<UserProfileSections, UserSettings>(
			section: .list,
			items: []
		)
		userDataSection.items.append(.plainWithTextfield(userName))
		let _ = userSettings.map { item in
			userDataSection.items.append(.plainWithLabel(item))
		}
		sections = [userHeaderSection, userDataSection]
	}
	
	//MARK: - User's profile picture helpers
	func fetchImageData(from data: Data) {
		userImage = data
	}
	
	func getImageResource() {
		guard let user = userService.user else { return }
		guard let stringUrl = user.userProfileImage else { return }
		if let url = URL(string: stringUrl) {
			userImageResource = .url(url)
		} else {
			userImageResource = .asset(Assets.userImagePlaceholder)
		}
	}
	
	//MARK: - Photo library permissions
	func askForPermissions() {
		permissionService.askForPermissions()
	}
	
	//MARK: - Network requests
	func fetchUser() {
		isLoadingSubject.send(true)
		guard let id = userService.user?.remoteId else { return }
		userService.fetchUser(id: id)
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
				userService.save(user: user)
				userName = user.name ?? ""
				userDiabetesType = user.diabetesType ?? ""
				userFastInsulin = user.fastActingInsulin ?? ""
				userBasalInsulin = user.basalInsulin ?? ""
				self.isLoadingSubject.send(false)
				self.updateDatasource()
			}
			.store(in: &cancellables)
	}
	
	func logoutUser() {
		isLoadingSubject.send(true)
		userService.logoutUser()
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
		guard
			let userImage = userImage,
			var user = userService.user
		else { return }
		let uploadData = MultipartDataItem(data: userImage,
										   attachmentKey: "",
										   fileName: Constants.basicUserProfileImageName)
		userService.uploadUserProfilePhoto(data: uploadData)
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .finished:
					debugPrint("Success")
					self.updateDatasource()
				case .failure(let error):
					Logger.error(error.localizedDescription)
				}
			} receiveValue: { [weak self] response in
				guard let self = self else { return }
				self.clearImageCache()
				user.userProfileImage = response.fileURL + "?\(UUID().uuidString)"
				self.updateUser(user)
			}
			.store(in: &cancellables)
	}
	
	func deleteUserProfilePhoto() {
		guard var user = userService.user else { return }
		userService.deletePhoto(filename: Constants.basicUserProfileImageName + Constants.basicImageFormat)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					debugPrint("Photo was deleted from backend")
					user.userProfileImage = ""
					self.updateUser(user)
					self.clearImageCache()
					self.updateDatasource()
				case .failure(let error):
					Logger.error(error.localizedDescription)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
	
	func updateUser(_ user: User) {
		isLoadingSubject.send(true)
		userService.updateUser(user: user)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				self.isLoadingSubject.send(false)
				switch completion {
				case .finished:
					debugPrint("User updated")
				case .failure(let error):
					Logger.error(error.localizedDescription)
				}
			} receiveValue: { [weak self] user in
				self?.updateDatasource()
			}
			.store(in: &cancellables)
	}
	
	func showPlaceholderDatasource() {
		let userHeaderModel = UserHeaderModel(email: Constants.loadingTitle, image: .asset(Assets.userImagePlaceholder))
		let userHeaderSection = SectionModel<UserProfileSections, UserSettings>(section: .header,
																				items: [.header(userHeaderModel)])
		let userSettings = [
			UserDataSettingsModel(title: Localization.name, textFieldValue: Constants.loadingTitle),
			UserDataSettingsModel(title: Localization.diabetsType, textFieldValue: Constants.loadingTitle),
			UserDataSettingsModel(title: Localization.fastActingInsulin, textFieldValue: Constants.loadingTitle),
			UserDataSettingsModel(title: Localization.basalInsulin, textFieldValue: Constants.loadingTitle)
		]
		var userDataSection = SectionModel<UserProfileSections, UserSettings>(section: .list, items: [])
		userDataSection.items = userSettings.map { .plainWithTextfield($0) }
		sections = [userHeaderSection, userDataSection]
	}
	
	func updatedUser() -> User? {
		guard var user = userService.user else {
			return nil
		}
		user.basalInsulin = userBasalInsulin
		user.name = userName
		user.diabetesType = userDiabetesType
		user.fastActingInsulin = userFastInsulin
		return user
	}
	
	func clearImageCache() {
		KingfisherManager.shared.cache.clearCache()
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let basicUserProfileImageName = "userProfileImage"
	static let basicImageFormat = ".jpeg"
	static let loadingTitle = "Loading..."
}
