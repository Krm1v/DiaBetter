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

struct BarChart: View {
	// MARK: - @State properties
	@State var model: BarChartCellModel
	@State private(set) var pickerState: LineChartState
	@State private(set) var treshold: Double?
	@State private var belowColor: Color = Color(uiColor: Colors.customMint.color)
	@State private var aboveColor: Color = .init(uiColor: Colors.customPink.color)
	@State private var scrollWidth: CGFloat = UIScreen.main.bounds.width * 2
	@State private var barWidth: CGFloat = 15.0

	// MARK: - Publishers
	private(set) lazy var chartActionPublisher = chartActionSubject.eraseToAnyPublisher()
	private let chartActionSubject = PassthroughSubject<BarChartActions, Never>()

	// MARK: - Views
	var body: some View {
		VStack {
			picker
				.padding(.bottom, 8)
			if pickerState == .glucose {

				ScrollView(.horizontal) {
					chart
						.frame(width: scrollWidth)
				}
				.scrollIndicators(.hidden)
			} else {
				chart
			}
		}
		.padding()
	}

	private var chart: some View {
		Chart(model.items, id: \.date) { item in
			BarMark(
				x: .value("Date", item.date.stringRepresentation(format: .dayTime)),
				y: .value("Value", item.yValue),
				width: pickerState == .glucose ? .automatic : .fixed(barWidth)
			)
			.foregroundStyle(
				item.isAbove(threshold: $treshold.wrappedValue ?? .zero) ? aboveColor.gradient : belowColor.gradient)
			.cornerRadius(7)

			if let treshold {
                RuleMark(y: .value("Theshold", treshold))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(Color(uiColor: Colors.customDarkenPink.color))
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
		.chartYAxis(.visible)
		.chartXAxis(.visible)
	}

	private var picker: some View {
		Picker("PickerContent", selection: $pickerState) {
			Text("Glucose").tag(LineChartState.glucose)
			Text("Carbs").tag(LineChartState.meal)
			Text("Insulin").tag(LineChartState.insulin)
		}
		.pickerStyle(.segmented)
		.onChange(of: pickerState) { newValue in
			chartActionSubject.send(.segmentedDidPressed(newValue))
		}
		.padding(.zero)
	}
}

// MARK: - Preview
struct Chart_Previews: PreviewProvider {
	static var previews: some View {
		BarChart(
			model: BarChartCellModel(
				state: .glucose,
				items: [BarChartItem(date: Date(), yValue: 8)]),
			pickerState: .glucose)
	}
}
