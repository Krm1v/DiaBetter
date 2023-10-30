//
//  ReportSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.03.2023.
//

import SwiftUI
import Combine
import Charts

struct ReportSceneView: View {
    
    @State var reportScenePropsModel: ReportSceneProps
    @State var treshold: Double?
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack {
                    createHeader(with: Localization.todayGlucose)
                        .padding(.bottom)
                    AreaChart(
                        glucoseData: reportScenePropsModel.areaChartModel,
                        treshold: treshold)
                    .padding(.bottom)
                    
                    createHeader(with: Localization.glucoseTrends)
                        .padding(.bottom)
                    
                    HStack {
                        if reportScenePropsModel.averageGlucoseChartModel.glucoseValue.isEmpty {
                            EmptyWidgetStateView(textMessage: Localization.noDataAvailable)
                                .frame(height: UIScreen.main.bounds.width / 5)
                        } else {
                            AverageGlucoseWidget(
                                model: reportScenePropsModel.averageGlucoseChartModel)
                            .frame(height: UIScreen.main.bounds.width / 5)
                        }
                        
                        if reportScenePropsModel.minMaxGlucoseValueChartModel.minValue.isEmpty {
                            EmptyWidgetStateView(textMessage: Localization.noDataAvailable)
                                .frame(height: UIScreen.main.bounds.width / 5)
                        } else {
                            MinMaxGlucoseValuesWidget(
                                model: reportScenePropsModel.minMaxGlucoseValueChartModel)
                            .frame(height: UIScreen.main.bounds.width / 5)
                        }
                    }
                    .padding(.bottom)
                    
                    createHeader(with: Localization.insulinUsage)
                        .padding(.bottom)
                    
                    InsulinBarChart(
                        insulinData: reportScenePropsModel.insulinBarChartModel.chartData, isDataExist: reportScenePropsModel.insulinBarChartModel.isDataExist)
                }
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Localization.today)
            .padding([.leading, .trailing])
        }
    }
}

struct ReportScenePreview: PreviewProvider {
    static var previews: some View {
        ReportSceneView(
            reportScenePropsModel: .init(areaChartModel: .init(),
                                         insulinBarChartModel: .init(isDataExist: true, chartData: .init()),
                                         averageGlucoseChartModel: .init(glucoseValue: "", glucoseUnit: ""), minMaxGlucoseValueChartModel: .init(minValue: "", maxValue: "")))
    }
}
