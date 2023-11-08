//
//  AreaChart.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.10.2023.
//

import SwiftUI
import Charts

struct AreaChart: View {
    // MARK: - Properties
    @State var glucoseData: [TodayAreaChartModel]
    @State private var chartColor: Color = .init(uiColor: Colors.customPink.color)
    @State var treshold: Double?
    @State private var belowColor: Color = Color(uiColor: Colors.customGreen.color)
    @State private var aboveColor: Color = .init(uiColor: Colors.customPink.color)
    
    // MARK: - Body
    var body: some View {
        if glucoseData.isEmpty {
            EmptyWidgetStateView(textMessage: Localization.noDataAvailable)
                .frame(height: Constants.emptyWidgetViewHeight)
        } else if glucoseData.count == 1 {
            EmptyWidgetStateView(textMessage: Localization.notEnoughData)
                .frame(height: Constants.emptyWidgetViewHeight)
        } else {
            chartView
        }
    }
    
    // MARK: - Chart
    private var chartView: some View {
        Chart(glucoseData) { element in
            AreaMark(
                x: .value(
                    "Time",
                    element.chartItem.xValue),
                y: .value(
                    "Glucose",
                    element.chartItem.yValue)
            )
            .foregroundStyle(gradient)
            .interpolationMethod(.cardinal)
            
            if let treshold {
                RuleMark(
                    y: .value("Theshold", treshold)
                )
                .lineStyle(
                    StrokeStyle(
                        lineWidth: Constants.defaultLineWidth
                    )
                )
                .foregroundStyle(
                    Color(
                        uiColor: Colors.customYellow.color
                    )
                )
                .annotation(
                    position: .top,
                    alignment: .topLeading
                ) {
                    
                    Text("\(treshold, specifier: "%.0f")")
                        .font(
                            .custom(
                                FontFamily.Montserrat.regular,
                                size: Constants.defaultFontSize
                            )
                        )
                        .foregroundColor(.primary)
                        .background {
                            
                            ZStack {
                                RoundedRectangle(
                                    cornerRadius: Constants.annotationCornerRadius
                                )
                                .fill(.background)
                                RoundedRectangle(
                                    cornerRadius: Constants.annotationCornerRadius
                                )
                                .fill(
                                    .quaternary.opacity(
                                        Constants.defaultOpacity
                                    )
                                )
                            }
                            .padding(.horizontal, -Constants.annotationHorizontalPadding)
                            .padding(.vertical, -Constants.annotationVerticalPadding)
                        }
                        .padding(.leading)
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width / 2)
    }
    
    // MARK: - Gradient
    private var gradient: Gradient {
        var colors = [chartColor]
        colors.append(chartColor.opacity(0))
        return Gradient(colors: colors)
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let emptyWidgetViewHeight: CGFloat = UIScreen.main.bounds.width / 2
    static let defaultLineWidth: CGFloat = 1
    static let annotationCornerRadius: CGFloat = 8
    static let defaultOpacity: CGFloat = 0.7
    static let annotationHorizontalPadding: CGFloat = 8
    static let annotationVerticalPadding: CGFloat = 4
    static let defaultFontSize: CGFloat = 13
}
