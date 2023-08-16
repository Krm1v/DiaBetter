//
//  AppEnvironment.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 16.12.2021.
//

import Foundation

enum AppEnvironment: String {
    case dev
    case stg
    case prod

    var baseURL: URL {
        switch self {
        case .dev: return URL(string: "https://api.backendless.com/" + apiKey)!
        case .stg: return URL(string: "https://api.backendless.com/" + apiKey)!
        case .prod: return URL(string: "https://api.backendless.com/" + apiKey)!
        }
    }
	
	var apiKey: String {
		guard
			let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String,
			let restApiKey = Bundle.main.infoDictionary?["RESTAPI_KEY"] as? String
		else { return "" }
		return apiKey + "/" + restApiKey
	}
}
