//
//  ChartsModels.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 23.05.2023.
//

import Foundation

struct BarChartItem: Hashable {
	let date: Date
	let yValue: Double
}

extension BarChartItem {
	func isAbove(threshold: Double) -> Bool {
		self.yValue > threshold
	}
}

struct BarChartCellModel: Hashable, Identifiable {
	let id = UUID()
	var state: LineChartState
	let items: [BarChartItem]
	var treshold: Double?
}

struct LineChartItem: Hashable, Identifiable {
	let id = UUID()
	let date: Date
	let yValue: Double
}

struct LineChartCellModel: Hashable, Identifiable {
	let id = UUID()
	let items: [LineChartItem]
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
