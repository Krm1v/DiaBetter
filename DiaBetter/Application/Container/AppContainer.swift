//
//  AppContainer.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import Foundation
import KeychainAccess

protocol AppContainer: AnyObject {
	var appConfiguration: AppConfiguration { get }
	var userService: UserService { get }
	var userNetworkService: UserNetworkService { get }
	var userAuthorizationService: UserAuthorizationService { get }
	var recordsService: RecordsService { get }
	var recordsNetworkService: RecordsNetworkService { get }
	var userNotificationManager: UserNotificationManager { get }
	var permissionService: PermissionService { get }
	var appSettingsService: SettingsService { get }
}

final class AppContainerImpl: AppContainer {
	// MARK: - Properties
	let appConfiguration: AppConfiguration
	let userService: UserService
	let userNetworkService: UserNetworkService
	let userAuthorizationService: UserAuthorizationService
	let recordsService: RecordsService
	let recordsNetworkService: RecordsNetworkService
	let userNotificationManager: UserNotificationManager
	let permissionService: PermissionService
	let appSettingsService: SettingsService

	// MARK: - Init
	init() {
		let appConfiguration = AppConfigurationImpl()
		self.appConfiguration = appConfiguration

		let keychain = Keychain(service: appConfiguration.bundleId)
		let tokenStorage = TokenStorageImpl(keychain: keychain)

		let tokenPlugin = TokenPlugin(tokenStorage: tokenStorage)
		let contentTypePlugin = JSONContentTypePlugin()

		let networkManager = NetworkManager()
		let userNetworkServiceProvider = NetworkServiceProviderImpl<UserEndpoint>(
			baseURLStorage: appConfiguration,
			networkManager: networkManager,
			plugins: [tokenPlugin, contentTypePlugin],
			encoder: JSONEncoder(),
			decoder: JSONDecoder())

		let authorizationNetworkService = NetworkServiceProviderImpl<UserAuthorizationEndpoint>(
			baseURLStorage: appConfiguration,
			networkManager: networkManager,
			encoder: JSONEncoder(),
			decoder: JSONDecoder())

		self.userNetworkService = UserNetworkServiceImpl(userNetworkServiceProvider)
		self.userAuthorizationService = UserAuthorizationServiceImpl(authorizationNetworkService,
																	 tokenStorage: tokenStorage)
		let recordNetworkProvider = NetworkServiceProviderImpl<RecordsEndpoint>(
			baseURLStorage: appConfiguration,
			networkManager: networkManager,
			plugins: [tokenPlugin, contentTypePlugin],
			encoder: JSONEncoder(),
			decoder: JSONDecoder())
		
		self.recordsNetworkService = RecordsNetworkServiceImpl(recordNetworkProvider)

		let userService = UserServiceImpl(userNetworkService: userNetworkService,
										  userAuthorizationService: userAuthorizationService,
										  tokenStorage: tokenStorage)
		self.userService = userService

		let recordService = RecordsServiceImpl(recordsNetworkService: recordsNetworkService,
											   tokenStorage: tokenStorage)
		self.recordsService = recordService
		let userNotificationManager = UserNotificationManagerImpl()
		self.userNotificationManager = userNotificationManager

		let permissionService = PermissionServiceImpl()
		self.permissionService = permissionService

		let appSettingsService = SettingsServiceImpl()
		self.appSettingsService = appSettingsService
	}
}
