//
//  AreaChart.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.10.2023.
//

import SwiftUI
import Charts

struct AreaChart: View {
    
    @State var glucoseData: [TodayAreaChartModel]
    @State private var chartColor: Color = .init(uiColor: Colors.customPink.color)
    @State var treshold: Double?
    
    var body: some View {
        if glucoseData.isEmpty {
            EmptyWidgetStateView(textMessage: "No data available")
        } else if glucoseData.count == 1 {
            EmptyWidgetStateView(textMessage: "No enought data. Add some more results to see your report.")
        } else {
            Chart(glucoseData) { element in
                AreaMark(
                    x: .value("Time", element.recordTime),
                    y: .value("Glucose", element.glucoseValue))
                .foregroundStyle(gradient)
                .interpolationMethod(.cardinal)
                
                if let treshold {
                    RuleMark(y: .value("Theshold", treshold))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(Color.white)
                        .annotation(
                            position: .top,
                            alignment: .topLeading) {

                            Text("\(treshold, specifier: "%.0f")")
                                .font(.custom(FontFamily.Montserrat.regular, size: 13))
                                .foregroundColor(.primary)
                                .background {

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.background)
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.quaternary.opacity(0.7))
                                    }
                                    .padding(.horizontal, -8)
                                    .padding(.vertical, -4)
                                }
                                .padding(.bottom, 4)
                        }
                }
            }
            .frame(height: UIScreen.main.bounds.width / 2)
        }
    }
    
    private var gradient: Gradient {
        var colors = [chartColor]
        colors.append(chartColor.opacity(0))
        return Gradient(colors: colors)
    }
}
