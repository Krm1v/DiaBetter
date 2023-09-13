//
//  AverageGlucoseCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.09.2023.
//

import SwiftUI

struct AverageGlucoseCell: View {

	@State var model: AverageGlucoseCellModel

	var body: some View {
		borderedMainContent
			.padding()
	}

	private var mainContent: some View {
		VStack {
			HStack {
				Spacer()

				Circle()
					.fill(Color(model.dotColor))
					.frame(
						width: 15,
						height: 15)
			}
			.padding(
				EdgeInsets(
					top: 8,
					leading: 8,
					bottom: .zero,
					trailing: 8))

			VStack {
				Text(model.period.title)
					.font(
						.custom(
							FontFamily.Montserrat.regular,
							size: 17))

				VStack {
					Text($model.glucoseValue.wrappedValue)

					Text($model.glucoseUnit.wrappedValue)
				}
				.font(
					.custom(
						FontFamily.Montserrat.semiBold,
						size: 15))
			}
			.padding(
				EdgeInsets(
					top: .zero,
					leading: 16,
					bottom: 16,
					trailing: 16))
		}
	}

	private var borderedMainContent: some View {
		mainContent
			.cornerRadius(12)
			.overlay(
				RoundedRectangle(cornerRadius: 12)
					.stroke(
						Color.white,
						lineWidth: 0.5)
			)
	}
}

struct AverageGlucoseCell_Preview: PreviewProvider {
	static var previews: some View {
		AverageGlucoseCell(model: AverageGlucoseCellModel(period: .overall, glucoseValue: "12", glucoseUnit: "mmol/l", dotColor: .green))
	}
}
