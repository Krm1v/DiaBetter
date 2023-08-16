//
//  RecordsEndpoint.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine

enum RecordsEndpoint: Endpoint {
	case addRecord(model: RecordRequestModel)
	case updateRecord(model: RecordRequestModel, id: String)
	case fetchRecords(userId: String)
	case deleteRecord(id: String)
	case bulkDetele(id: String)
	case bulkAddRecords(model: [RecordRequestModel])
	case filterRecords(userId: String, startDate: Double, endDate: Double)

	// MARK: - Properties
	var path: String? {
		switch self {
		case .addRecord: 			   return "/data/Records"
		case .updateRecord(_, let id): return "/data/Records/\(id)"
		case .fetchRecords: 		   return "/data/Records"
		case .deleteRecord(let id):    return "/data/Records/\(id)"
		case .bulkDetele:			   return "/data/bulk/Records"
		case .bulkAddRecords:		   return "/data/bulk/Records"
		case .filterRecords:		   return "/data/Records"
		}
	}
	var httpMethod: HTTPMethods {
		switch self {
		case .addRecord: 	  return .post
		case .bulkAddRecords: return .post
		case .updateRecord:   return .put
		case .fetchRecords:   return .get
		case .deleteRecord:   return .delete
		case .bulkDetele:     return .delete
		case .filterRecords:  return .get
		}
	}

	var queries: HTTPQueries {
		switch self {
		case .fetchRecords(let id):
			let ownerId = QueryParameters(
				key: .ownerId,
				value: .equalToString(stringValue: id)).queryString

			let recordDate = QueryParameters(
				key: .recordDate,
				value: .equalToString(stringValue: "")).queryString

			return [
				.filter: ownerId,
				.sort: recordDate
			]

		case .bulkDetele(let id):
			let ownerId = QueryParameters(
				key: .ownerId,
				value: .equalToString(stringValue: id)
			).queryString

			return [.filter: ownerId]

		case .filterRecords(let id, let startDate, let endDate):
			let idFilter = QueryParameters(
				key: .ownerId,
				value: .equalToString(stringValue: id)
			).queryString

			let dateFilter = QueryParameters(
				key: .recordDate,
				value: .dateRange(startDate: startDate, endDate: endDate)
			).queryString

			return [
				.filter: "\(idFilter) and \(dateFilter)"
			]

		default: return [:]
		}
	}

	var headers: HTTPHeaders {
		switch self {
		case .addRecord, .updateRecord, .fetchRecords, .deleteRecord, .bulkDetele, .bulkAddRecords, .filterRecords:
			return ["": ""]
		}
	}

	var body: RequestBody? {
		switch self {
		case .addRecord(model: let recordModel), .updateRecord(model: let recordModel, _):
			return .encodable(recordModel)

		case .bulkAddRecords(model: let records):
			return .encodable(records)

		case .deleteRecord, .fetchRecords, .bulkDetele, .filterRecords:
			return nil
		}
	}
}
