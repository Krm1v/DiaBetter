//
//  BarChart.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.09.2023.
//

import SwiftUI
import Charts

struct BarChart: View {
    // MARK: - @State properties
    @State private(set) var model: GlucoseBarChartModel
    @State private(set) var treshold: Double?
    @State private var belowColor: Color = Color(uiColor: Colors.customGreen.color)
    @State private var aboveColor: Color = .init(uiColor: Colors.customPink.color)
    @State private var scrollWidth: CGFloat = UIScreen.main.bounds.width * 2
    
    // MARK: - Views
    // MARK: - Body
    var body: some View {
        chart
            .frame(height: UIScreen.main.bounds.width / 2)
    }
    
    // MARK: - Chart
    private var chart: some View {
        Chart(model.data, id: \.xValue) { item in
            BarMark(
                x: .value("Date",
                          item.xValue),
                y: .value("Value",
                          item.yValue),
                width: 3)
            .foregroundStyle(
                item.isAbove(threshold: $treshold.wrappedValue ?? .zero) ? aboveColor.gradient : belowColor.gradient
            )
            .position(
                by: .value("Value",
                           item.yValue)
            )
            .cornerRadius(Constants.defaultCornerRadius)
            
            if let treshold {
                RuleMark(
                    y: .value("Theshold",
                              treshold)
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
                    alignment: .topLeading,
                    spacing: Constants.defaultSpacing) {
                        
                        Text(treshold.convertToString())
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
                                        cornerRadius: Constants.defaultCornerRadius
                                    )
                                    .fill(.background)
                                    RoundedRectangle(
                                        cornerRadius: Constants.defaultCornerRadius
                                    )
                                    .fill(
                                        .quaternary.opacity(
                                            Constants.defaultOpacity
                                        )
                                    )
                                }
                                .padding(
                                    .horizontal, -Constants.annotationHorizontalPadding
                                )
                                .padding(
                                    .vertical,
                                    -Constants.annotationVerticalPadding
                                )
                            }
                            .padding(.leading)
                    }
            }
        }
        .chartYAxis(.visible)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day(.twoDigits))
            }
        }
        .chartForegroundStyleScale([
            Localization.notInRange: Color(
                uiColor: Colors.customPink.color),
            Localization.inRange: Color(
                uiColor: Colors.customGreen.color)
        ])
    }
}

// MARK: - Preview
struct Chart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart(
            model:
                    .init(data: [.init(xValue: Date(), yValue: 10),
                                 .init(xValue: Date(), yValue: 5.6)],
                          treshold: 11))
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultCornerRadius: CGFloat = 7
    static let defaultLineWidth: CGFloat = 1
    static let defaultFontSize: CGFloat = 13
    static let defaultSpacing: CGFloat = 8
    static let defaultOpacity: CGFloat = 0.7
    static let annotationVerticalPadding: CGFloat = 4
    static let annotationHorizontalPadding: CGFloat = 8
}
