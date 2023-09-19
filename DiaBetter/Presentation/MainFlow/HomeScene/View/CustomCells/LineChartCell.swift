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
	@State private var scrollWidth: CGFloat = UIScreen.main.bounds.width * 2

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
		Chart {
			ForEach(model.items) { item in
				LineMark(
					x: .value("Date", item.date.stringRepresentation(format: .dayTime)),
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
		.padding(EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: 16))
		.frame(width: scrollWidth)
	}
}

// MARK: - Preview
struct LineChart_Previews: PreviewProvider {
	static var previews: some View {
		LineChartCell(model: LineChartCellModel(
			items: [LineChartItem(date: Date(), yValue: 5)])
		)
	}
}
