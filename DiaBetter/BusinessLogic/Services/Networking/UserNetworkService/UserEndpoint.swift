//
//  UserEndpoint.swift
//  CombineNetworkManagerTest
//
//  Created by Владислав Баранкевич on 13.02.2023.
//

import Foundation
import Combine

enum UserEndpoint: Endpoint {
    case delete(id: String)
    case update(user: UserUpdateRequestModel, id: String)
    case fetchUser(id: String)
    case restorePassword(userEmail: String)
    case logout
    case uploadPhoto(data: MultipartDataItem, userId: String)
    case deletePhoto(filename: String, userId: String)
    
    // MARK: - Properties
    var path: String? {
        switch self {
        case .delete(let id):
            return "/data/Users/\(id)"
        case .update(_, let id):
            return "/data/Users/\(id)"
        case .fetchUser(let id):
            return "/data/Users/\(id)"
        case .restorePassword(let email):
            return "/users/restorepassword/\(email)"
        case .logout:
            return "/users/logout"
        case .uploadPhoto(let data, let userId):
            return "/files/images/users/\(userId)/\(data.fileName)"
        case .deletePhoto(let filename, let userId):
            return "/files/images/users/\(userId)/\(filename).jpeg"
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
            return [.overwrite: "true"]
        default: return [:]
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        default: return [:]
        }
    }
    
    var body: RequestBody? {
        switch self {
        case .update(let user, _):
            return .encodable(user)
        case .delete, .restorePassword, .fetchUser, .logout, .deletePhoto:
            return nil
        case let .uploadPhoto(data, _):
            return .multipartData([data])
        }
    }
}
