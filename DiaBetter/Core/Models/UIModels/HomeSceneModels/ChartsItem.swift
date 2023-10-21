//
//  ChartsItem.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 23.05.2023.
//

import Foundation

struct ChartItem {
	let xValue: Date
	let yValue: Double
}

extension ChartItem {
    func isAbove(threshold: Double) -> Bool {
        self.yValue > threshold
    }
}

struct HomeSceneWidgetPropsModel: Identifiable {
    let id = UUID()
    var glucoseChartModel: GlucoseBarChartModel
    var averageGlucoseChartModel: [AverageGlucoseChartModel]
    var lineChartHomeWidgetModel: LineChartHomeWidgetModel
}

struct GlucoseBarChartModel: Identifiable {
    let id = UUID()
    let data: [ChartItem]
    let treshold: Double
}

struct AverageGlucoseChartModel: Identifiable {
    enum RecordsPeriod: CaseIterable {
        case overall
        case threeMonth
        case week
        
        var title: String {
            switch self {
            case .overall: return Localization.overall
            case .threeMonth: return Localization._3m
            case .week: return Localization.week
            }
        }
    }
    
    let id = UUID()
    let averageValue: String
    let glucoseUnit: SettingsUnits.GlucoseUnitsState
    var dotColor: ColorAsset.Color = .clear
    var period: RecordsPeriod
}

struct LineChartHomeWidgetModel: Identifiable {
    let id = UUID()
    let data: [ChartItem]
}
