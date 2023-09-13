//
//  ChartsModels.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 23.05.2023.
//

import Foundation

struct LineChartItem: Hashable {
	let xValue: Double
	let yValue: Double
}

struct LineChartCellModel: Hashable, Identifiable {
	let id = UUID()
	var state: LineChartState
	let items: [ChartItem]
}

struct GlucoseLevelPerPeriodWidgetModel: Hashable {
	let filter: WidgetFilterState
	let items: [ChartItem]
}

struct InsulinUsageChartModel: Hashable {
	let filter: WidgetFilterState
	let fastInsulin: [ChartItem]
	let basalInsulin: [ChartItem]
}
