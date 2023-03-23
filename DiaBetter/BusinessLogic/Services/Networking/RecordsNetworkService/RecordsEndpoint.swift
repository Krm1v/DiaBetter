//
//  RecordsEndpoint.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine

fileprivate enum PathStrings {
	static let addRecord = "/data/Records"
	static let updateRecord = "/data/Records/"
	static let fetchRecords = "/data/Records"
	static let deleteRecord = "data/Records/"
}

enum RecordsEndpoint: Endpoint {
	case addRecord(RecordRequestModel, String)
	case updateRecord(recordModel: RecordRequestModel, userToken: String, objectId: String)
	case fetchRecords(String)
	case deleteRecord(String)
	
	//MARK: - Properties
	var path: String? {
		switch self {
		case .addRecord:
			return PathStrings.addRecord
		case .updateRecord(recordModel: _, userToken: _, objectId: let objectId):
			return PathStrings.updateRecord + objectId
		case .fetchRecords:
			return PathStrings.fetchRecords
		case .deleteRecord(let objectId):
			return PathStrings.deleteRecord + objectId
		}
	}
	var httpMethod: HTTPMethods {
		switch self {
		case .addRecord:
			return .post
		case .updateRecord:
			return .put
		case .fetchRecords:
			return .get
		case .deleteRecord:
			return .delete
		}
	}
	
	var queries: HTTPQueries {
		switch self {
		default: return [:]
		}
	}
	
	var headers: HTTPHeaders {
		switch self {
		case .addRecord(_, let token), .updateRecord(recordModel: _, userToken: let token, objectId: _), .fetchRecords(let token), .deleteRecord(let token):
			return ["Content-Type": "application/json", "user-token": "\(token)"]
		}
	}
	
	var body: RequestBody? {
		switch self {
		case .addRecord(let recordModel, _), .updateRecord(recordModel: let recordModel, userToken: _, objectId: _):
			return .encodable(recordModel)
		case .deleteRecord, .fetchRecords:
			return nil
		}
	}
}

