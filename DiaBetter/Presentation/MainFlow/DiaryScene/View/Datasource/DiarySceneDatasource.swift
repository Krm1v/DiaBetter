//
//  Datasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.04.2023.
//

import Foundation

// MARK: - Sections
enum DiarySceneSection: Hashable {
	case main(RecordSectionModel?)
}

extension DiarySceneSection: RawRepresentable {
	// MARK: - Typealiases
	typealias RawValue = Int

	// MARK: - Properties
	var rawValue: RawValue {
		switch self {
		case .main: return 0
		}
	}

	var title: String? {
		switch self {
		case .main(let model):
			return model?.title
		}
	}

	var id: UUID? {
		switch self {
		case .main(let model):
			return model?.id
		}
	}

	// MARK: - Init
	init?(rawValue: RawValue) {
		switch rawValue {
		case 0: self = .main(nil)
		default: return nil
		}
	}

	// MARK: - Methods
	public static func == (lhs: DiarySceneSection, rhs: DiarySceneSection) -> Bool {
		return lhs.id == rhs.id && lhs.title == rhs.title
	}
}

// MARK: - Items
enum DiarySceneItem: Hashable {
	case record(DiaryRecordCellModel)
}
