//
//  ChartsItem+Charts.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 23.05.2023.
//

import Charts

struct ChartItem: Hashable {
	let x: Double
	let y: Double
	
	var entry: ChartDataEntry {
		ChartDataEntry(x: x, y: y)
	}
}
