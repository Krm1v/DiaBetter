//
//  Datasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.05.2023.
//

import Foundation

struct HomeSectionModel: Hashable {
	let id = UUID()
	let title: String
}

// MARK: - Sections
enum ChartSection: Hashable {
	case barChart(HomeSectionModel?)
	case averageGlucose(HomeSectionModel?)
	case lineChart(HomeSectionModel?)
}

extension ChartSection: RawRepresentable {
	// MARK: - Typealiases
	typealias RawValue = Int

	// MARK: - Properties
	var rawValue: RawValue {
		switch self {
		case .barChart: 	  return 0
		case .averageGlucose: return 1
		case .lineChart:	  return 2
		}
	}

	var title: String? {
		switch self {
		case .barChart(let model):
			return model?.title
		case .averageGlucose(let model):
			return model?.title
		case .lineChart(let model):
			return model?.title
		}
	}

	// MARK: - Init
	init?(rawValue: RawValue) {
		switch rawValue {
		case 0: self = .barChart(nil)
		case 1: self = .averageGlucose(nil)
		case 2: self = .lineChart(nil)
		default: return nil
		}
	}

	// MARK: - Methods
	public static func == (lhs: ChartSection, rhs: ChartSection) -> Bool {
		return lhs.rawValue == rhs.rawValue
	}
}

// MARK: - Items
enum ChartsItems: Hashable {
	case barChart(LineChartCellModel)
	case averageGlucose(AverageGlucoseCellModel)
	case lineChart(LineChartCellModel)
}

// MARK: - States
enum LineChartState: String, CaseIterable, Identifiable {
	case glucose
	case insulin
	case meal

	var id: Self { self }

	var title: String {
		switch self {
		case .glucose: return Localization.glucose
		case .insulin: return Localization.insulin
		case .meal:    return Localization.meal
		}
	}
}

enum WidgetFilterState: Int, CaseIterable {
	case day
	case week
	case month

	var title: String {
		switch self {
		case .day: 	 return "1d"
		case .week:  return "7d"
		case .month: return "30d"
		}
	}
}

struct AverageGlucoseCellModel: Hashable, Identifiable {
	let id = UUID()
	let period: AverageGlucosePeriods
	var glucoseValue: String
	var glucoseUnit: String
	var dotColor: ColorAsset.Color
}

enum AverageGlucosePeriods: Hashable {
	case overall
	case week
	case threeMonth

	var title: String {
		switch self {
		case .overall: return "Overall"
		case .week: return "Week"
		case .threeMonth: return "3 m."
		}
	}
}
