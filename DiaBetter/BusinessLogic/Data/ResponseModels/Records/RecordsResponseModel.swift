//
//  RecordsResponseModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation

struct RecordsResponseModel: Decodable {
	enum CodingKeys: String, CodingKey {
		case meal, longInsulin, glucoseLevel, created, recordDate, fastInsulin
		case recordNote, ownerId, recordId
		case objectID = "objectId"
	}

	let recordId: 	  String
	let meal: 		  Decimal?
	let longInsulin:  Decimal?
	let glucoseLevel: Decimal?
	let created: 	  Int?
	let recordNote:   String?
	let fastInsulin:  Decimal?
	let objectID: 	  String
	let recordDate:   Double
	let ownerId: 	  String
}
