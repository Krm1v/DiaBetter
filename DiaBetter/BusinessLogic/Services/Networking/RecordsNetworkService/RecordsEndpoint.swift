//
//  RecordsEndpoint.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine

enum RecordsEndpoint: Endpoint {
	case addRecord(RecordRequestModel)
	case updateRecord(RecordRequestModel, String)
	case fetchRecords
	case deleteRecord(String)
	
	//MARK: - Properties
	var path: String? {
		switch self {
		case .addRecord:
			return "/data/Records"
		case .updateRecord(_, let id):
			return "/data/Records/\(id)"
		case .fetchRecords:
			return "/data/Records"
		case .deleteRecord(let id):
			return "data/Records/\(id)"
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
		case .addRecord, .updateRecord, .fetchRecords, .deleteRecord:
			return ["": ""]
		}
	}
	
	var body: RequestBody? {
		switch self {
		case .addRecord(let recordModel), .updateRecord(let recordModel, _):
			return .encodable(recordModel)
		case .deleteRecord, .fetchRecords:
			return nil
		}
	}
}

