//
//  UnitsDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.06.2023.
//

import Foundation

enum MinMaxGlucoseTarget: Hashable {
	case min
	case max
}

enum SettingsUnits {
	enum GlucoseUnitsState: Int, CaseIterable, Codable {
		case mmolL
		case mgDl

		var title: String {
			switch self {
			case .mmolL: return "mmol/L"
			case .mgDl: return "mg/dL"
			}
		}
	}

	enum CarbsUnits: Int, CaseIterable, Codable {
		case grams
		case breadUnits

		var description: String {
			switch self {
            case .grams: 	  return Localization.grams
            case .breadUnits: return Localization.breadUnits
			}
		}

		var title: String {
			switch self {
            case .grams: 	  return Localization.gramsShortened
            case .breadUnits: return Localization.breadUnitsShortened
			}
		}
	}
}

// MARK: - Sections and items
enum UnitsSceneSections: Hashable {
	case main(UnitsSectionModel?)
	case glucoseTarget(UnitsSectionModel?)
}

extension UnitsSceneSections: RawRepresentable {
	// MARK: - Typealiases
	typealias RawValue = Int

	// MARK: - Properties
	var rawValue: RawValue {
		switch self {
		case .main: 		 return 0
		case .glucoseTarget: return 1
		}
	}

	var title: String? {
		switch self {
		case .main(let model): 			return model?.title
		case .glucoseTarget(let model): return model?.title
		}
	}

	var id: UUID? {
		switch self {
		case .main(let model): 			return model?.id
		case .glucoseTarget(let model): return model?.id
		}
	}

	// MARK: - Init
	init?(rawValue: RawValue) {
		switch rawValue {
		case 0: self = .main(nil)
		case 1: self = .glucoseTarget(nil)
		default: return nil
		}
	}

	// MARK: - Methods
	public static func == (lhs: UnitsSceneSections, rhs: UnitsSceneSections) -> Bool {
		return lhs.id == rhs.id && lhs.title == rhs.title
	}
}

enum UnitsSceneItems: Hashable {
	case plainWithSegmentedControl(GlucoseUnitsCellModel)
	case plainWithUIMenu(CarbsUnitsCellModel)
	case plainWithStepper(TargetGlucoseCellModel)
}
