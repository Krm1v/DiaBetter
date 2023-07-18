//
//  RecordRequestModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation

struct RecordRequestModel: Encodable {
	let fastInsulin: Decimal?
	let longInsulin: Decimal?
	let recordNote: String?
	let glucoseLevel: Decimal?
	let meal: Decimal?
	let recordDate: String?
	let ownerId: String
}

