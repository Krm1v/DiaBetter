//
//  Record.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation

struct Record: Codable {
	let meal: Decimal?
	let fastInsulin: Decimal?
	let glucoseLevel: Decimal?
	let longInsulin: Decimal?
	let objectId: String?
	let recordDate: Int
	let recordNote: String?
	let recordType: String
	
	init(meal: Decimal? = nil,
		 fastInsulin: Decimal? = nil,
		 glucoseLevel: Decimal? = nil,
		 longInsulin: Decimal? = nil,
		 objectId: String? = nil,
		 recordDate: Int,
		 recordNote: String? = nil,
		 recordType: String) {
		self.meal = meal
		self.fastInsulin = fastInsulin
		self.glucoseLevel = glucoseLevel
		self.longInsulin = longInsulin
		self.objectId = objectId
		self.recordDate = recordDate
		self.recordNote = recordNote
		self.recordType = recordType
	}
	
	init(_ response: RecordsResponseModel) {
		self.meal = response.meal
		self.fastInsulin = response.fastInsulin
		self.glucoseLevel = response.glucoseLevel
		self.longInsulin = response.longInsulin
		self.objectId = response.objectID
		self.recordDate = response.recordDate
		self.recordNote = response.recordNote
		self.recordType = response.recordType
	}
}
