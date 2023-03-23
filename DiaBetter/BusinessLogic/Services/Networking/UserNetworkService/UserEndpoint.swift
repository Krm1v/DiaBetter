//
//  UserEndpoint.swift
//  CombineNetworkManagerTest
//
//  Created by Владислав Баранкевич on 13.02.2023.
//

import Foundation
import Combine

fileprivate enum PathStrings {
	static let delete = "/data/Users/"
	static let update = "/data/Users/"
	static let fetch = "/data/Users/"
	static let restorePassword = "/users/restorepassword/"
	static let logout = "/users/logout"
	static let uploadPhoto = "/files/Photos"
	static let deletePhoto = "/files/Photos/"
}

enum UserEndpoint: Endpoint {
	case delete(objectID: String)
	case update(user: UserUpdateRequestModel, objectID: String, token: String)
	case fetchUser(token: String, objectId: String)
	case restorePassword(userEmail: String)
	case logout(token: String)
	case uploadPhoto(token: String, data: MultipartDataItem)
	case deletePhoto(token: String, filename: String)
	
	//MARK: - Properties
	var path: String? {
		switch self {
		case .delete(let objectID):
			return PathStrings.delete + objectID
		case .update(_, let objectID, _):
			return PathStrings.update + objectID
		case .fetchUser(_, let objectID):
			return PathStrings.fetch + objectID
		case .restorePassword(let email):
			return PathStrings.restorePassword + email
		case .logout:
			return PathStrings.logout
		case .uploadPhoto:
			return PathStrings.uploadPhoto
		case .deletePhoto(_, let filename):
			return PathStrings.deletePhoto + filename
		}
	}
	var httpMethod: HTTPMethods {
		switch self {
		case .uploadPhoto:
			return .post
		case .update:
			return .put
		case .fetchUser, .restorePassword, .logout:
			return .get
		case .delete, .deletePhoto:
			return .delete
		}
	}
	
	var queries: HTTPQueries {
		switch self {
		case .uploadPhoto:
			return ["overwrite": "true"]
		default: return [:]
		}
	}
	
	var headers: HTTPHeaders {
		switch self {
		case .delete:
			return ["Content-Type": "application/json"]
		case .logout(let token), .update(_, _, let token), .fetchUser(let token, _):
			return ["Content-Type": "application/json", "user-token": "\(token)"]
		case .restorePassword:
			return [:]
		case .uploadPhoto(let token, _), .deletePhoto(let token, _):
			return ["user-token": "\(token)"]
		}
	}
	
	var body: RequestBody? {
		switch self {
		case .update(let user, _, _):
			return .encodable(user)
		case .delete, .restorePassword, .fetchUser, .logout, .deletePhoto:
			return nil
		case let .uploadPhoto(_, data):
			return .multipartData([data])
		}
	}
}
