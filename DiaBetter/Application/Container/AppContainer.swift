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
    var settingsService: SettingsService { get }
    var unitsConvertManager: UnitsConvertManager { get }
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
    let settingsService: SettingsService
    let unitsConvertManager: UnitsConvertManager
    
    // MARK: - Init
    init() {
        // MARK: - App configuration
        let appConfiguration = AppConfigurationImpl()
        self.appConfiguration = appConfiguration
        
        // MARK: - Token
        let keychain = Keychain(service: appConfiguration.bundleId)
        let tokenStorage = TokenStorageImpl(keychain: keychain)
        
        // MARK: - Plugins
        let tokenPlugin = TokenPlugin(tokenStorage: tokenStorage)
        let contentTypePlugin = JSONContentTypePlugin()
        
        // MARK: - Network manager
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
        self.userAuthorizationService = UserAuthorizationServiceImpl(
            authorizationNetworkService,
            tokenStorage: tokenStorage)
        let recordNetworkProvider = NetworkServiceProviderImpl<RecordsEndpoint>(
            baseURLStorage: appConfiguration,
            networkManager: networkManager,
            plugins: [tokenPlugin, contentTypePlugin],
            encoder: JSONEncoder(),
            decoder: JSONDecoder())
        
        self.recordsNetworkService = RecordsNetworkServiceImpl(recordNetworkProvider)
        
        // MARK: - User service
        let userService = UserServiceImpl(
            userNetworkService: userNetworkService,
            userAuthorizationService: userAuthorizationService,
            tokenStorage: tokenStorage)
        self.userService = userService
        
        // MARK: - Record service
        let recordService = RecordsServiceImpl(
            recordsNetworkService: recordsNetworkService,
            tokenStorage: tokenStorage)
        self.recordsService = recordService
        
        // MARK: - Notification manager
        let userNotificationManager = UserNotificationManagerImpl()
        self.userNotificationManager = userNotificationManager
        
        // MARK: - Permission service
        let permissionService = PermissionServiceImpl()
        self.permissionService = permissionService
        
        // MARK: - App settings
        let settingsService = SettingsServiceImpl()
        self.settingsService = settingsService
        
        // MARK: - Units converter
        let unitsConvertManager = UnitsConvertManagerImpl(settingsService: settingsService)
        self.unitsConvertManager = unitsConvertManager
    }
}
