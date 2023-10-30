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
    var body: some View {
            chart
                .frame(height: UIScreen.main.bounds.width / 2)
    }
    
    private var chart: some View {
        Chart(model.data, id: \.xValue) { item in
            BarMark(
                x: .value("Date", item.xValue, unit: .day),
                y: .value("Value", item.yValue), width: 3)
            .foregroundStyle(
                item.isAbove(threshold: $treshold.wrappedValue ?? .zero) ? aboveColor.gradient : belowColor.gradient)
            .position(by: .value("Value", item.yValue))
            .cornerRadius(7)
            
            if let treshold {
                RuleMark(y: .value("Theshold", treshold))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(Color(uiColor: Colors.customYellow.color))
                    .annotation(
                        position: .top,
                        alignment: .topLeading,
                        spacing: 8) {
                            
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
            Localization.notInRange: Color(uiColor: Colors.customPink.color),
            Localization.inRange: Color(uiColor: Colors.customGreen.color)
        ])
    }
}

// MARK: - Preview
struct Chart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart(model: .init(data: [.init(xValue: Date(), yValue: 10), .init(xValue: Date(), yValue: 5.6)], treshold: 11))
    }
}
