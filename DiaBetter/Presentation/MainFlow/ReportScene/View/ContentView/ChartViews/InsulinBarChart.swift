//
//  InsulinBarChart.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 11.10.2023.
//

import SwiftUI
import Charts

struct InsulinBarChart: View {
    // MARK: - Properties
    @State var insulinData: [TodayInsulinModel]
    @State var isDataExist: Bool
    
    // MARK: - Body
    var body: some View {
        if !isDataExist {
            EmptyWidgetStateView(textMessage: Localization.noDataAvailable)
                .frame(height: UIScreen.main.bounds.width / 2)
        } else {
            Chart(insulinData) { insulinItems in
                ForEach(insulinItems.data, id: \.id) {
                    BarMark(
                        x: .value(
                            "Time",
                            $0.recordTime, unit: .hour),
                        y: .value(
                            "InsulinValue",
                            $0.insulinValue)
                    )
                    .foregroundStyle(
                        by: .value(
                            "Insulin type",
                            insulinItems.insulinType.title)
                    )
                    .position(
                        by: .value(
                            "insulin",
                            insulinItems.insulinType.title)
                    )
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing)
            }
            .chartXAxis {
                AxisMarks(
                    values: .stride(by: .hour)
                ) { _ in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel(
                        format: .dateTime.hour(),
                        centered: true
                    )
                }
            }
            .chartForegroundStyleScale([
                insulinData.first?.insulinType.title ?? "": Color.blue,
                insulinData.last?.insulinType.title ?? "": Color(uiColor: Colors.customGreen.color)
            ])
            .frame(height: UIScreen.main.bounds.width / 2)
        }
    }
}

// MARK: - Preview
struct InsulinBarChart_Preview: PreviewProvider {
    static var previews: some View {
        InsulinBarChart(insulinData: .init(), isDataExist: true)
    }
}
