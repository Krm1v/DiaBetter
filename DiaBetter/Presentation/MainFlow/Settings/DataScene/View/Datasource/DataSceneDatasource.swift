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

struct AppleHealthSectionModel: Hashable {
	let id = UUID()
	let title: String?
}

enum DataSceneSections: Hashable {
	case appleHealth(AppleHealthSectionModel?)
	case backup
}

extension DataSceneSections: RawRepresentable {
	//MARK: - Typealiases
	typealias RawValue = Int
	
	//MARK: - Properties
	var rawValue: RawValue {
		switch self {
		case .appleHealth: return 0
		case .backup: 	   return 1
		}
	}
	
	var title: String? {
		switch self {
		case .appleHealth(let model): return model?.title
		case .backup: 		   		  return nil
		}
	}
	
	var id: UUID? {
		switch self {
		case .appleHealth(let model): return model?.id
		case .backup: 				  return nil
		}
	}
	
	//MARK: - Init
	init?(rawValue: RawValue) {
		switch rawValue {
		case 0: self = .appleHealth(nil)
		case 1: self = .backup
		default: return nil
		}
	}
	
	//MARK: - Methods
	public static func == (lhs: DataSceneSections, rhs: DataSceneSections) -> Bool {
		return lhs.id == rhs.id && lhs.title == rhs.title
	}
}

enum DataSceneItems: Hashable {
	case appleHealthItem(AppleHealthCellModel)
	case backupItem(BackupCellModel)
}

enum BackupListSectionItems: Hashable {
	case backup
}
