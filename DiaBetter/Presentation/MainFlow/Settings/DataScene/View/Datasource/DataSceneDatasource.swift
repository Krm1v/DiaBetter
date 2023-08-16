//
//  DataSceneDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.07.2023.
//

import Foundation

struct AppleHealthCellModel: Hashable {
	let title: String
	let isConnected: Bool
}

struct BackupCellModel: Hashable {
	let title: String
	let item: BackupListSectionItems
}

struct DataSceneSectionsModel: Hashable, Identifiable {
	let id = UUID()
	let title: String?
}

enum DataSceneSections: Hashable {
	case appleHealth(DataSceneSectionsModel?)
	case backup(DataSceneSectionsModel?)
	case importSection(DataSceneSectionsModel?)
}

extension DataSceneSections: RawRepresentable {
	// MARK: - Typealiases
	typealias RawValue = Int

	// MARK: - Properties
	var rawValue: RawValue {
		switch self {
		case .appleHealth: 	 return 0
		case .backup: 	   	 return 1
		case .importSection: return 2
		}
	}

	var title: String? {
		switch self {
		case .appleHealth(let model):   return model?.title
		case .backup(let model):        return model?.title
		case .importSection(let model): return model?.title
		}
	}

	var id: UUID? {
		switch self {
		case .appleHealth(let model): 	return model?.id
		case .backup(let model): 		return model?.id
		case .importSection(let model): return model?.id
		}
	}

	// MARK: - Init
	init?(rawValue: RawValue) {
		switch rawValue {
		case 0: self = .appleHealth(nil)
		case 1: self = .backup(nil)
		case 2: self = .importSection(nil)
		default: return nil
		}
	}

	// MARK: - Methods
	public static func == (lhs: DataSceneSections, rhs: DataSceneSections) -> Bool {
		return lhs.id == rhs.id && lhs.title == rhs.title
	}
}

enum DataSceneItems: Hashable {
	case appleHealthItem(AppleHealthCellModel)
	case backupItem(BackupCellModel)
	case importItem(BackupCellModel)
}

enum BackupListSectionItems: Hashable {
	case backup
	case importItem
}
