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
    // MARK: - Properties
    @State var reportScenePropsModel: ReportSceneProps
    @State var treshold: Double?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    createHeader(with: Localization.todayGlucose)
                    
                    AreaChart(
                        glucoseData: reportScenePropsModel.areaChartModel,
                        treshold: treshold
                    )
                    .padding(.bottom)
                    
                    createHeader(with: Localization.glucoseTrends)
                    
                    HStack {
                        if reportScenePropsModel.averageGlucoseChartModel.glucoseValue.isEmpty {
                            EmptyWidgetStateView(textMessage: Localization.noDataAvailable)
                                .frame(height: Constants.emptyStateViewHeight)
                        } else {
                            AverageGlucoseWidget(
                                model: reportScenePropsModel.averageGlucoseChartModel)
                            .frame(height: Constants.emptyStateViewHeight)
                        }
                        
                        if reportScenePropsModel.minMaxGlucoseValueChartModel.minValue.isEmpty {
                            EmptyWidgetStateView(textMessage: Localization.noDataAvailable)
                                .frame(height: Constants.emptyStateViewHeight)
                        } else {
                            MinMaxGlucoseValuesWidget(
                                model: reportScenePropsModel.minMaxGlucoseValueChartModel)
                            .frame(height: Constants.emptyStateViewHeight)
                        }
                    }
                    .padding(.bottom)
                    
                    createHeader(with: Localization.insulinUsage)
                    
                    InsulinBarChart(
                        insulinData: reportScenePropsModel.insulinBarChartModel.chartData,
                        isDataExist: reportScenePropsModel.insulinBarChartModel.isDataExist
                    )
                }
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Localization.today)
            .padding([.leading, .trailing])
        }
    }
}

// MARK: - Preview
struct ReportScenePreview: PreviewProvider {
    static var previews: some View {
        ReportSceneView(
            reportScenePropsModel:
                    .init(areaChartModel: .init(),
                          insulinBarChartModel:
                            .init(isDataExist: true, chartData: .init()),
                          averageGlucoseChartModel:
                            .init(glucoseValue: "", glucoseUnit: ""),
                          minMaxGlucoseValueChartModel: .init(minValue: "", maxValue: "")))
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let emptyStateViewHeight: CGFloat = UIScreen.main.bounds.width / 5
}
