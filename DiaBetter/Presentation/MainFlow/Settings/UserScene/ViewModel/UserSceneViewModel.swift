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
	typealias UserSection = SectionModel<UserProfileSections, UserSettings>

	// MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private(set) var permissionService: PermissionService
	private let transitionSubject = PassthroughSubject<UserSceneTransition, Never>()
	private let userService: UserService

	// MARK: - Published properties
	@Published private(set) var userImage: Data?
	@Published private var userImageResource: ImageResource?
	@Published var sections: [UserSection] = []
	@Published var userName = ""
	@Published var userDiabetesType = ""
	@Published var userFastInsulin = ""
	@Published var userBasalInsulin = ""

	// MARK: - Init
	init(userService: UserService, permissionService: PermissionService) {
		self.permissionService = permissionService
		self.userService = userService
		super.init()
	}

	override func onViewDidLoad() {
		fetchUser()
		showPlaceholderDatasource()
	}

	override func onViewWillDisappear() {
		guard let user = updatedUser() else {
			return
		}
		updateUser(user)
		isLoadingSubject.send(false)
	}

	// MARK: - Public methods
	// MARK: - User's profile picture helpers
	func fetchImageData(from data: Data) {
		userImage = data
	}

	func getImageResource() {
		guard let user = userService.user else {
			return
		}

		guard let stringUrl = user.userProfileImage else {
			return
		}

		if let url = URL(string: stringUrl) {
			userImageResource = .url(url)
		} else {
			userImageResource = .asset(Assets.userImagePlaceholder)
		}
	}

	// MARK: - Photo library permissions
	func askForPhotoPermissions() {
		permissionService.askForPhotoPermissions()
	}

	// MARK: - Network requests
	func fetchUser() {
		guard let id = userService.user?.remoteId else {
			return
		}
		isLoadingSubject.send(true)
		userService.fetchUser(id: id)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					Logger.info("Finished")
					self.isLoadingSubject.send(false)
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.isLoadingSubject.send(false)
					errorSubject.send(error)
				}
			} receiveValue: { [weak self] user in
				guard let self = self else {
					return
				}
				userName = user.name ?? ""
				userDiabetesType = user.diabetesType ?? ""
				userFastInsulin = user.fastActingInsulin ?? ""
				userBasalInsulin = user.basalInsulin ?? ""
				self.updateDatasource()
			}
			.store(in: &cancellables)
	}

	func logoutUser() {
		isLoadingSubject.send(true)
		userService.logoutUser()
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					self.userService.clear()
					self.isLoadingSubject.send(false)
					self.transitionSubject.send(.success)
					Logger.info("Finished")
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.errorSubject.send(error)
					self.isLoadingSubject.send(false)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}

	func uploadUserProfileImage() {
		guard
			let userImage = userImage,
			var user = userService.user
		else {
			return
		}
		let uploadData = MultipartDataItem(
			data: userImage,
			attachmentKey: "",
			fileName: Constants.basicUserProfileImageName)

		userService.uploadUserProfilePhoto(data: uploadData)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .finished:
					Logger.info("Finished")
					self.updateDatasource()
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { [weak self] response in
				guard let self = self else {
					return
				}
				self.clearImageCache()
				user.userProfileImage = response.fileURL + "?\(UUID().uuidString)"
				self.updateUser(user)
			}
			.store(in: &cancellables)
	}

	func deleteUserProfilePhoto() {
		guard var user = userService.user else {
			return
		}
		userService.deletePhoto(filename: Constants.basicUserProfileImageName + MimeTypes.jpeg)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					Logger.info("Finished")
					user.userProfileImage = ""
					self.updateUser(user)
					self.clearImageCache()
					self.updateDatasource()
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}

	func updateUser(_ user: User) {
		isLoadingSubject.send(true)
		userService.updateUser(user: user)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}

				switch completion {
				case .finished:
					self.isLoadingSubject.send(false)
					Logger.info("Finished")
				case .failure(let error):
					Logger.error(error.localizedDescription)
					errorSubject.send(error)
				}
			} receiveValue: { [weak self] _ in
				guard let self = self else {
					return
				}
				self.updateDatasource()
			}
			.store(in: &cancellables)
	}

	func showPlaceholderDatasource() {
		let userHeaderModel = UserHeaderModel(
			email: Constants.loadingTitle,
			image: .asset(Assets.userImagePlaceholder))

		let userHeaderSection = UserSection(
			section: .header,
			items: [
				.header(userHeaderModel)])

		let userSettings = [
			UserDataSettingsModel(
				title: Localization.name,
				textFieldValue: Constants.loadingTitle),

			UserDataSettingsModel(
				title: Localization.diabetsType,
				textFieldValue: Constants.loadingTitle),

			UserDataSettingsModel(
				title: Localization.fastActingInsulin,
				textFieldValue: Constants.loadingTitle),

			UserDataSettingsModel(
				title: Localization.basalInsulin,
				textFieldValue: Constants.loadingTitle)]

		var userDataSection = UserSection(
			section: .list,
			items: [])

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

private extension UserSceneViewModel {
	func updateDatasource() {
		getImageResource()
		guard let user = userService.user else {
			return
		}
		let userHeaderModel = UserHeaderModel(
			email: user.email ?? "",
			image: userImageResource)

		let userHeaderSection = UserSection(
			section: .header,
			items: [
				.header(userHeaderModel)])

		let userName = UserDataSettingsModel(
			title: Localization.name,
			textFieldValue: user.name ?? "")

		let userSettings = [
			UserDataMenuSettingsModel(
				rowTitle: Localization.diabetsType,
				labelValue: user.diabetesType ?? "",
				source: .diabetesType),

			UserDataMenuSettingsModel(
				rowTitle: Localization.fastActingInsulin,
				labelValue: user.fastActingInsulin ?? "",
				source: .fastInsulin),

			UserDataMenuSettingsModel(
				rowTitle: Localization.basalInsulin,
				labelValue: user.basalInsulin ?? "",
				source: .longInsulin)
		]
		var userDataSection = UserSection(
			section: .list,
			items: [])

		userDataSection.items.append(.plainWithTextfield(userName))
		_ = userSettings.map { item in
			userDataSection.items.append(.plainWithLabel(item))
		}
		sections = [userHeaderSection, userDataSection]
	}
}

// MARK: - Constants
private enum Constants {
	static let basicUserProfileImageName = "userProfileImage"
	static let loadingTitle = "Loading..."
}
