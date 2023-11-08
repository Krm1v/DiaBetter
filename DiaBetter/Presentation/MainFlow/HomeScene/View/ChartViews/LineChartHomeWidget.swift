//
//  LineChartCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.09.2023.
//

import SwiftUI
import Charts

struct LineChartHomeWidget: View {
    // MARK: - @State properties
    @State var model: LineChartHomeWidgetModel
    @State private var scrollWidth = Constants.scrollViewWidth
    
    // MARK: - Views
    // MARK: - Body
    var body: some View {
        ScrollView(.horizontal) {
            chart
                .frame(
                    width: scrollWidth,
                    height: Constants.scrollViewHeight
                )
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Chart
    private var chart: some View {
        Chart {
            ForEach(model.data, id: \.xValue) { item in
                LineMark(
                    x: .value(
                        "Date",
                        item.xValue,
                        unit: .day),
                    y: .value(
                        "Value",
                        item.yValue)
                )
                .interpolationMethod(.cardinal)
                .symbolSize(Constants.defaultSymbolSize)
            }
        }
        .foregroundColor(
            Color(
                uiColor: Colors.customPink.color
            )
        )
        .chartYAxis {
            AxisMarks(
                preset: .automatic,
                position: .leading
            )
        }
        .chartXAxis {
            AxisMarks(
                preset: .automatic,
                position: .bottom,
                values: .stride(by: .day)
            ) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(
                    format: .dateTime.day(.twoDigits)
                )
            }
        }
    }
}

// MARK: - Preview
struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        LineChartHomeWidget(model: .init(data: []))
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let scrollViewWidth: CGFloat = UIScreen.main.bounds.width * 2
    static let scrollViewHeight: CGFloat = UIScreen.main.bounds.width / 2
    static let defaultSymbolSize: CGFloat = 50
}
