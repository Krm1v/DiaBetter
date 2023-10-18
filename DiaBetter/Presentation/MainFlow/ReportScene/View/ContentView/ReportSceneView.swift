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
                        .padding(.bottom, 8)
                    AreaChart(
                        glucoseData: reportScenePropsModel.areaChartModel,
                        treshold: treshold)
                    .padding(.bottom)
                    
                    createHeader(with: Localization.glucoseTrends)
                        .padding(.bottom, 8)
                    
                    HStack {
                        if reportScenePropsModel.averageGlucoseChartModel.glucoseValue.isEmpty {
                            smallEmptyStateView
                        } else {
                            AverageGlucoseWidget(
                                model: reportScenePropsModel.averageGlucoseChartModel)
                            .frame(height: UIScreen.main.bounds.width / 5)
                        }
                        
                        if reportScenePropsModel.minMaxGlucoseValueChartModel.minValue.isEmpty, reportScenePropsModel.minMaxGlucoseValueChartModel.maxValue.isEmpty {
                            smallEmptyStateView
                        } else {
                            MinMaxGlucoseValuesWidget(
                                model: reportScenePropsModel.minMaxGlucoseValueChartModel)
                            .frame(height: UIScreen.main.bounds.width / 5)
                        }
                    }
                    .padding(.bottom)
                    
                    createHeader(with: Localization.insulinUsage)
                        .padding(.bottom, 8)
                    
                    InsulinBarChart(
                        insulinData: reportScenePropsModel.insulinBarChartModel)
                }
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Localization.today)
            .padding([.leading, .trailing])
        }
    }
    
    private var smallEmptyStateView: EmptyWidgetStateView? {
        return EmptyWidgetStateView(textMessage: Localization.noDataAvailable)
            .frame(height: UIScreen.main.bounds.width / 5) as? EmptyWidgetStateView
    }
    
    func createHeader(with title: String) -> some View {
        HStack {
            Text(title)
                .font(.custom(FontFamily.Montserrat.semiBold, size: 20))
            
            Spacer()
        }
    }
}

struct ReportScenePreview: PreviewProvider {
    static var previews: some View {
        ReportSceneView(
            reportScenePropsModel: .init(areaChartModel: .init(),
                                         insulinBarChartModel: .init(),
                                         averageGlucoseChartModel: .init(glucoseValue: "", glucoseUnit: ""), minMaxGlucoseValueChartModel: .init(minValue: "", maxValue: "")))
    }
}
