//
//  UserAuthorizationService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 02.03.2023.
//

import Foundation
import Combine

fileprivate enum PathStrings {
	static let registration = "/users/register"
	static let login = "/users/login"
}

enum UserAuthorizationEndpoint: Endpoint {
	case register(user: UserRequestModel)
	case login(credentials: Login)
	
	//MARK: - Properties
	var path: String? {
		switch self {
		case .register:
			return PathStrings.registration
		case .login:
			return PathStrings.login
		}
	}
	
	var httpMethod: HTTPMethods {
		switch self {
		case .register, .login:
			return .post
		}
	}
	
	var queries: HTTPQueries {
		switch self {
		default: return [:]
		}
	}
	
	var headers: HTTPHeaders {
		switch self {
		case .register, .login:
			return ["Content-Type": "application/json"]
		}
	}
	
	var body: RequestBody? {
		switch self {
		case .register(let user):
			return .encodable(user)
		case .login(let credentials):
			return .encodable(credentials)
		}
	}
}

