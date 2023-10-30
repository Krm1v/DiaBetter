//
//  ReportChartsDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.10.2023.
//

import Foundation

struct ReportSceneProps: Identifiable {
    let id = UUID()
    var treshold: Double?
    var areaChartModel: [TodayAreaChartModel]
    var insulinBarChartModel: TodayInsulinChartModel
    var averageGlucoseChartModel: TodayAverageGlucoseChartModel
    var minMaxGlucoseValueChartModel: TodayMinMaxGlucoseValuesChartModel
}

struct TodayAreaChartModel: Identifiable {
    let id = UUID()
    let chartItem: ChartItem
}

struct TodayInsulinChartModel: Identifiable {
    let id = UUID()
    var isDataExist: Bool
    var chartData: [TodayInsulinModel]
}

struct TodayInsulinModel: Identifiable {
    enum InsulinType {
        case fast(String)
        case basal(String)
        
        var title: String {
            switch self {
            case .fast(let title):
                return title
            case .basal(let title):
                return title
            }
        }
    }
    
    let id = UUID()
    let insulinType: InsulinType
    let data: [InsulinChartModel]
}

struct InsulinChartModel: Identifiable {
    let id = UUID()
    let recordTime: Date
    let insulinValue: Double
}

struct TodayAverageGlucoseChartModel: Identifiable {
    let id = UUID()
    let glucoseValue: String
    var dotColor: ColorAsset.Color = Colors.customPink.color
    let glucoseUnit: String
}

struct TodayMinMaxGlucoseValuesChartModel: Identifiable {
    let id = UUID()
    let minValue: String
    let maxValue: String
}
