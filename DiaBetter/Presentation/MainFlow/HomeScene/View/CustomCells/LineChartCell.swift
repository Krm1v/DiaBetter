//
//  LineChartCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.09.2023.
//

import SwiftUI
import Charts
import Combine

struct LineChartCell: View {
	// MARK: - @State properties
	@State var model: LineChartCellModel
	@State private var scrollWidth: CGFloat = 1000

	// MARK: - Publisher
	private(set) lazy var chartActionPublisher = chartActionSubject.eraseToAnyPublisher()
	private let chartActionSubject = PassthroughSubject<BarChartActions, Never>()

	// MARK: - Views
	var body: some View {
		ScrollView(.horizontal) {
			chart
		}
		.scrollIndicators(.hidden)
	}

	private var chart: some View {
		Chart(model.items) { item in
			Plot {
				LineMark(
					x: .value("Date", "\(item.xValue.stringRepresentation(format: .day))"),
					y: .value("Value", "\(item.yValue)"))
			}
		}
		.foregroundColor(Color(uiColor: Colors.customPink.color))
		.chartYAxis {
			AxisMarks(preset: .automatic)
		}
		.chartYAxis(.visible)
		.padding()
		.frame(width: scrollWidth)
	}
}

// MARK: - Preview
struct LineChart_Previews: PreviewProvider {
	static var previews: some View {
		BarChart(model: LineChartCellModel(state: .glucose, items: [ChartItem(xValue: Date(timeIntervalSince1970: 1688206800.0), yValue: 8.6)]), pickerContent: .glucose)
	}
}
