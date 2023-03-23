//
//  AppConfiguration.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import Foundation

protocol AppConfiguration: BaseURLStorage {
    var bundleId: String { get }
    var environment: AppEnvironment { get }
	var baseURL: URL { get }
}

final class AppConfigurationImpl: AppConfiguration {
	//MARK: - Properties
	lazy var baseURL: URL = {
		return environment.baseURL
	}()
    let bundleId: String
    let environment: AppEnvironment
    
	//MARK: - Init
    init(bundle: Bundle = .main) {
        guard
            let bundleId = bundle.bundleIdentifier,
            let infoDict = bundle.infoDictionary,
            let environmentValue = infoDict[Key.Environment] as? String,
            let environment = AppEnvironment(rawValue: environmentValue)
        else {
            fatalError("config file error")
        }
        
        self.bundleId = bundleId
        self.environment = environment

        debugPrint(environment)
        debugPrint(bundleId)
    }
}

//MARK: - Fileprivate enum
fileprivate enum Key {
    static let Environment: String = "APP_ENVIRONMENT"
}
