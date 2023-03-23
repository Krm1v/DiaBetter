//
//  AppContainer.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import Foundation

protocol AppContainer: AnyObject {
    var appConfiguration: AppConfiguration { get }
    var userService: UserService { get }
    var appSettingsService: AppSettingsService { get }
	var userNetworkService: UserNetworkService { get }
	var userAuthorizationService: UserAuthorizationService { get }
	var recordsService: RecordsService { get }
	var recordsNetworkService: RecordsNetworkService { get }
}

final class AppContainerImpl: AppContainer {
	//MARK: - Properties
    let appConfiguration: AppConfiguration
    let userService: UserService
    let appSettingsService: AppSettingsService
	let userNetworkService: UserNetworkService
	let userAuthorizationService: UserAuthorizationService
	let recordsService: RecordsService
	let recordsNetworkService: RecordsNetworkService

	//MARK: - Init
    init() {
        let appConfiguration = AppConfigurationImpl()
        self.appConfiguration = appConfiguration

        let appSettingsService = AppSettingsServiceImpl()
        self.appSettingsService = appSettingsService
		
		let recordsService = RecordsServiceImpl(configuration: appConfiguration)
		self.recordsService = recordsService
		
		let networkManager = NetworkManager()
		let networkService = NetworkServiceProviderImpl<UserEndpoint>(
			baseURLStorage: appConfiguration,
			networkManager: networkManager,
			encoder: JSONEncoder(),
			decoder: JSONDecoder())
		let authorizationNetworkService = NetworkServiceProviderImpl<UserAuthorizationEndpoint>(baseURLStorage: appConfiguration,
																								networkManager: networkManager,
																								encoder: JSONEncoder(),
																								decoder: JSONDecoder())
		self.userNetworkService = UserNetworkServiceImpl(networkService)
		self.userAuthorizationService = UserAuthorizationServiceImpl(authorizationNetworkService)
		
		let userService = UserServiceImpl(configuration: appConfiguration, userNetworkService: userNetworkService)
		self.userService = userService
		
		let userNetworkService = NetworkServiceProviderImpl<RecordsEndpoint>(
			baseURLStorage: appConfiguration,
			networkManager: networkManager,
			encoder: JSONEncoder(),
			decoder: JSONDecoder())
		self.recordsNetworkService = RecordsNetworkServiceImpl(userNetworkService)
    }
}
