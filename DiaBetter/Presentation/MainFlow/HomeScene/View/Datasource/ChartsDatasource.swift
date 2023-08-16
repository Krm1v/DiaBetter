//
//  Datasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.05.2023.
//

import Foundation

// MARK: - Sections
enum ChartSection: Hashable {
	case lineChart
	case cubicLineChart
	case insulinUsage
}

extension ChartSection: RawRepresentable {
	// MARK: - Typealiases
	typealias RawValue = Int

	// MARK: - Properties
	var rawValue: RawValue {
		switch self {
		case .lineChart: 	  return 0
		case .cubicLineChart: return 1
		case .insulinUsage:   return 2
		}
	}

	// MARK: - Init
	init?(rawValue: RawValue) {
		switch rawValue {
		case 0: self = .lineChart
		case 1: self = .cubicLineChart
		case 2: self = .insulinUsage
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
	case lineChart(LineChartCellModel)
	case cubicLineChart(GlucoseLevelPerPeriodWidgetModel)
	case insulinUsage(InsulinUsageChartModel)
}

// MARK: - States
enum LineChartState: Int, CaseIterable {
	case glucose
	case insulin
	case meal

	var title: String {
		switch self {
		case .glucose: return Localization.glucose
		case .insulin: return Localization.insulin
		case .meal:    return Localization.meal
		}
	}

	var imageName: String {
		switch self {
		case .glucose: return "drop.fill"
		case .insulin: return "syringe.fill"
		case .meal:	   return "carrot.fill"
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
