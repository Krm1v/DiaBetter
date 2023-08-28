//
//  QueryAssembler.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.08.2023.
//

import Foundation

enum Queries: String, Hashable {
	case sort = "sortBy"
	case filter = "where"
	case overwrite = "overwrite"
	case pageSize = "pageSize"
	case offset = "offset"
}

enum QueryParametersKeys: String, Hashable {
	case ownerId
	case recordDate
	case pageSize
	case offset
}

enum QueryParametersValues: Hashable {
	case equalToString(stringValue: String)
	case equalToTildaString(stringValue: String)
	case greaterOrEqualThan(stringValue: String)
	case lessOrEqualThan(stringValue: String)
	case dateRange(startDate: Double, endDate: Double)
}

struct QueryParameters: Hashable {
	let key: QueryParametersKeys
	var value: QueryParametersValues

	var queryString: String {
		switch value {
		case .equalToString(let stringValue):
			return "\(key) = '\(stringValue)'"
		case .equalToTildaString:
			return "\(key)"
		case .greaterOrEqualThan(let stringValue):
			return "\(key) >= '\(stringValue)'"
		case .lessOrEqualThan(let stringValue):
			return "\(key) <= '\(stringValue)'"
		case .dateRange(let startDate, let endDate):
			return "\(key) >= '\(startDate)' and \(key) <= '\(endDate)'"
		}
	}
}
