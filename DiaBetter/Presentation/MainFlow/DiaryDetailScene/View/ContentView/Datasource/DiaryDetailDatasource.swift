//
//  DiaryDetailDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 11.06.2023.
//

import Foundation

struct DiaryDetailModel {
	//MARK: - Properties
	let date: Date
	let glucose: String
	let meal: String
	let fastInsulin: String
	let longInsulin: String
	let note: String
	
	//MARK: - Init
	init(_ record: Record) {
		self.date = record.recordDate ?? Date()
		self.glucose = record.glucoseLevel?.convertToString() ?? "∅"
		self.meal = record.meal?.convertToString() ?? "∅"
		self.fastInsulin = record.fastInsulin?.convertToString() ?? "∅"
		self.longInsulin = record.longInsulin?.convertToString() ?? "∅"
		self.note = record.recordNote ?? ""
	}
}
