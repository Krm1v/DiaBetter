//
//  ChartsItem+Charts.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 23.05.2023.
//

import Charts

struct ChartItem: Hashable {
	let xValue: Double
	let yValue: Double

	var entry: ChartDataEntry {
		ChartDataEntry(x: xValue, y: yValue)
	}
}
