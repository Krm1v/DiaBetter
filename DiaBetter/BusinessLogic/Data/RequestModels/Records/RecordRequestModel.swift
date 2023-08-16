//
//  RecordRequestModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation

struct RecordRequestModel: Encodable {
	let recordId: 	  String
	let fastInsulin:  Decimal?
	let longInsulin:  Decimal?
	let recordNote:   String?
	let glucoseLevel: Decimal?
	let recordDate:   Double
	let meal: 		  Decimal?
	let ownerId: 	  String
}
