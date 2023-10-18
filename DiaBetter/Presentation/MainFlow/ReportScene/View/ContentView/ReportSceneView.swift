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
                    createHeader(with: "Today's glucose")
                    AreaChart(
                        glucoseData: reportScenePropsModel.areaChartModel,
                        treshold: treshold)
                    .padding(.bottom)
                    
                    createHeader(with: "Glucose trends")
            
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
                    
                    createHeader(with: "Insulin")
                    InsulinBarChart(
                        insulinData: reportScenePropsModel.insulinBarChartModel)
                }
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Localization.report)
            .padding([.leading, .trailing])
        }
    }
    
    private var smallEmptyStateView: EmptyWidgetStateView? {
        return EmptyWidgetStateView(textMessage: "No data available")
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
