//
//  ChartsItem+Charts.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 23.05.2023.
//

import Foundation

struct ChartItem: Hashable, Identifiable {
	let id = UUID()
	let xValue: Date
	let yValue: Double

//	var entry: ChartDataEntry {
//		ChartDataEntry(x: xValue, y: yValue)
//	}
}
