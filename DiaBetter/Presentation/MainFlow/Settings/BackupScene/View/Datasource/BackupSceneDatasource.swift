//
//  BackupSceneDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.07.2023.
//

import Foundation

protocol BackupCellModelProtocol {
	associatedtype ListItem: Hashable
	var item: ListItem { get set }
}

struct BackupDateCellModel: BackupCellModelProtocol, Hashable {
	typealias ListItem = BackupDateItems
	
	let title: String
	let date: Date
	var item: ListItem
}

struct BackupShareCellModel: BackupCellModelProtocol, Hashable {
	typealias ListItem = BackupPlainItems
	
	let title: String
	let color: TextTypeColors
	var item: ListItem
}

struct BackupSectionModel: Hashable {
	let id = UUID()
	let title: String?
}

enum BackupSceneSections: Hashable {
	case backupDateSection(BackupSectionModel?)
	case shareSection(BackupSectionModel?)
	case eraseDataSection(BackupSectionModel?)
}

extension BackupSceneSections: RawRepresentable {
	//MARK: - Typealiases
	typealias RawValue = Int
	
	//MARK: - Properties
	var rawValue: RawValue {
		switch self {
		case .backupDateSection: return 0
		case .shareSection: 	 return 1
		case .eraseDataSection:  return 2
		}
	}
	
	var title: String? {
		switch self {
		case .backupDateSection(let model): return model?.title
		case .shareSection(let model): 	 	return model?.title
		case .eraseDataSection(let model): 	return model?.title
		}
	}
	
	var id: UUID? {
		switch self {
		case .backupDateSection(let model): return model?.id
		case .shareSection(let model): 	 	return model?.id
		case .eraseDataSection(let model): 	return model?.id
		}
	}
	
	//MARK: - Init
	init?(rawValue: RawValue) {
		switch rawValue {
		case 0: self = .backupDateSection(nil)
		case 1: self = .shareSection(nil)
		case 2: self = .eraseDataSection(nil)
		default: return nil
		}
	}
	
	//MARK: - Methods
	public static func == (lhs: BackupSceneSections, rhs: BackupSceneSections) -> Bool {
		return lhs.id == rhs.id && lhs.title == rhs.title
	}
}

enum BackupSceneItems: Hashable {
	case datePickerItem(BackupDateCellModel)
	case plainItem(BackupShareCellModel)
}

enum BackupDateItems: Hashable {
	case startDate
	case endDate
}

enum BackupPlainItems: Hashable {
	case backupAllData
	case createBackup
	case shareData
	case eraseAllData
}



