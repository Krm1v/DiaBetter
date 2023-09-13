//
//  BarChart.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.09.2023.
//

import SwiftUI
import Charts
import Combine

enum BarChartActions {
	case segmentedDidPressed(LineChartState)
}

enum PickerContent: String, CaseIterable, Identifiable {
	case glucose, carbs, insulin

	var id: Self { self }
}

struct BarChart: View {
	// MARK: - @State properties
	@State var model: LineChartCellModel
	@State private(set) var pickerContent: LineChartState

	// MARK: - Publisher
	private(set) lazy var chartActionPublisher = chartActionSubject.eraseToAnyPublisher()
	private let chartActionSubject = PassthroughSubject<BarChartActions, Never>()

	// MARK: - Views
	var body: some View {
		VStack {
			picker
			chart
		}
		.padding()
	}

	private var chart: some View {
		Chart(model.items) { item in
			BarMark(
				x: .value("Date", "\(item.xValue.stringRepresentation(format: .dayTime))"),
				y: .value("Value", "\(item.yValue)"))
		}
		.foregroundColor(Color(uiColor: Colors.customPink.color))
		.font(.custom(FontFamily.Montserrat.regular, size: 7))
		.padding(.zero)
	}

	private var picker: some View {
		Picker("PickerContent", selection: $pickerContent) {
			Text("Glucose").tag(LineChartState.glucose)
			Text("Carbs").tag(LineChartState.meal)
			Text("Insulin").tag(LineChartState.insulin)
		}
		.pickerStyle(.segmented)
		.onChange(of: pickerContent) { newValue in
			chartActionSubject.send(.segmentedDidPressed(newValue))
		}
		.padding(.zero)
	}
}

// MARK: - Preview
struct Chart_Previews: PreviewProvider {
	static var previews: some View {
		BarChart(model: LineChartCellModel(state: .glucose, items: [ChartItem(xValue: Date(timeIntervalSince1970: 1688206800.0), yValue: 8.6)]), pickerContent: .glucose)
	}
}
