//
//  AppConfiguration.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import Foundation

protocol BaseURLStorage {
	var baseURL: URL { get }
}

protocol AppConfiguration: BaseURLStorage {
    var bundleId: String { get }
    var environment: AppEnvironment { get }
}

final class AppConfigurationImpl: AppConfiguration {
	//MARK: - Private properties
	private let apiKey: String
	private let appId: String
	private let apiURL: String
	
	//MARK: - Properties
	let bundleId: String
	let environment: AppEnvironment
	
	lazy var baseURL: URL = {
		guard let url = URL(string: apiURL) else {
			assert(false, "Invalid URL")
		}
		let fullURL = url.appendingPathComponent(appId).appendingPathComponent(apiKey)
		
		return fullURL
	}()
    
	//MARK: - Init
    init(bundle: Bundle = .main) {
        guard
            let bundleId = bundle.bundleIdentifier,
            let infoDict = bundle.infoDictionary,
            let environmentValue = infoDict[Key.Environment] as? String,
			let apiKey = infoDict[Key.ApiKey] as? String,
			let appId = infoDict[Key.AppId] as? String,
			let apiURL = infoDict[Key.BaseUrl] as? String,
            let environment = AppEnvironment(rawValue: environmentValue)
        else {
			assert(false, "Config file error")
        }
        
        self.bundleId = bundleId
        self.environment = environment
		self.apiKey = apiKey
		self.appId = appId
		self.apiURL = apiURL

        debugPrint(environment)
        debugPrint(bundleId)
		debugPrint("⚙️ \(baseURL)")
		debugPrint("----------------------------------------------------")
    }
}

//MARK: - Fileprivate enum
fileprivate enum Key {
	static let Environment: String = "APP_ENVIRONMENT"
	static let ApiKey: String = "API_KEY"
	static let AppId: String = "APP_ID"
	static let BaseUrl: String = "BASE_URL"
}
