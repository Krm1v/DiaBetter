//
//  Record.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation

struct Record: Codable, Hashable {
	let recordId: String
	let meal: Decimal?
	let fastInsulin: Decimal?
	let glucoseLevel: Decimal?
	let longInsulin: Decimal?
	let objectId: String
	let recordDate: Date
	let recordNote: String?
	let userId: String
	
	init(
		recordId: String = UUID().uuidString,
		meal: Decimal? = nil,
		fastInsulin: Decimal? = nil,
		glucoseLevel: Decimal? = nil,
		longInsulin: Decimal? = nil,
		objectId: String,
		recordDate: Date = Date(),
		recordNote: String? = nil,
		userId: String
	) {
		self.recordId = recordId
		self.meal = meal
		self.fastInsulin = fastInsulin
		self.glucoseLevel = glucoseLevel
		self.longInsulin = longInsulin
		self.objectId = objectId
		self.recordDate = recordDate
		self.recordNote = recordNote
		self.userId = userId
	}
	
	init(_ response: RecordsResponseModel) {
		self.recordId = response.recordId
		self.meal = response.meal
		self.fastInsulin = response.fastInsulin
		self.glucoseLevel = response.glucoseLevel
		self.longInsulin = response.longInsulin
		self.objectId = response.objectID
		let timeInterval = TimeInterval(response.recordDate)
		self.recordDate = Date(timeIntervalSince1970: timeInterval / 1000)
		self.recordNote = response.recordNote
		self.userId = response.ownerId
	}
}
