//
//  RecordsResponseModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation

struct RecordsResponseModel: Decodable {
	let meal: Decimal?
	let longInsulin: Decimal?
	let glucoseLevel: Decimal?
	let recordType: String
	let created: Int?
	let recordNote: String?
	let fastInsulin: Decimal?
	let objectID: String?
	let recordDate: Int
	
	enum CodingKeys: String, CodingKey {
		case meal, longInsulin, glucoseLevel, recordType, created, recordDate
		case recordNote
		case fastInsulin
		case objectID = "objectId"
	}
}
