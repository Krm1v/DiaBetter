//
//  ChartsModels.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 23.05.2023.
//

import Foundation

struct LineChartItem: Hashable {
	let x: Double
	let y: Double
}

struct LineChartCellModel: Hashable {
	let state: LineChartState
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
