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
    @State private var scrollWidth: CGFloat = UIScreen.main.bounds.width * 2
    
    // MARK: - Views
    var body: some View {
        ScrollView(.horizontal) {
            chart
                .frame(width: scrollWidth, height: UIScreen.main.bounds.width / 2)
        }
        .scrollIndicators(.hidden)
    }
    
    private var chart: some View {
        Chart {
            ForEach(model.data, id: \.xValue) { item in
                LineMark(
                    x: .value("Date", item.xValue.stringRepresentation(format: .dayTime)),
                    y: .value("Value", item.yValue)
                )
                .interpolationMethod(.cardinal)
                .symbolSize(50)
            }
        }
        .foregroundColor(Color(uiColor: Colors.customPink.color))
        .chartYAxis {
            AxisMarks(preset: .automatic)
        }
        .chartYAxis(.visible)
    }
}

// MARK: - Preview
struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        LineChartHomeWidget(model: .init(data: []))
    }
}
