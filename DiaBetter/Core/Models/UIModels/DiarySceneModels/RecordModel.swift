//
//  RecordModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 27.04.2023.
//

import Foundation

struct DiaryRecordCellModel: Hashable {
	struct Info: Hashable {
		let value: String?
		let unit: String
	}

	// MARK: - Properties
	let id: String
	let time: String
	let glucoseInfo: Info
	let mealInfo: Info
	let fastInsulinInfo: Info
	let longInsulinInfo: Info

	// MARK: - Init
	init(_ record: Record, user: User) {
		self.id = record.objectId
		self.time = record.recordDate.stringRepresentation(format: .hourMinute)

		self.glucoseInfo = Info(
			value: record.glucoseLevel?.convertToString() ?? "∅",
			unit: GlucoseLevelUnits.mmolL.description
		)
		self.mealInfo = Info(
			value: record.meal?.convertToString() ?? "∅",
			unit: MealUnits.breadUnits.description
		)
		self.fastInsulinInfo = Info(
			value: record.fastInsulin?.convertToString() ?? "∅",
			unit: user.fastActingInsulin ?? ""
		)
		self.longInsulinInfo = Info(
			value: record.longInsulin?.convertToString() ?? "∅",
			unit: user.basalInsulin ?? ""
		)
	}
}

struct DateRecord: Hashable {
	let id = UUID()
	let date: Date
	var records: [DiaryRecordCellModel]
}
