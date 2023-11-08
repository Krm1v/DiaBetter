//
//  MinMaxGlucoseValuesWidget.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.10.2023.
//

import SwiftUI

struct MinMaxGlucoseValuesWidget: View {
    // MARK: - Properties
    @State var model: TodayMinMaxGlucoseValuesChartModel
    
    // MARK: - Body
    var body: some View {
        
        ZStack {
            RoundedRectangle(
                cornerRadius: Constants.defaultCornerRadius
            )
            .fill(.white)
            .overlay {
                RoundedRectangle(
                    cornerRadius: Constants.defaultCornerRadius
                )
                .fill(.black)
                .padding(1)
                .overlay {
                    VStack {
                        
                        HStack {
                            Spacer()
                            Text("\(Localization.lowestToday): \(model.minValue)")
                            Spacer()
                        }
                        
                        Divider()
                            .frame(height: 1)
                            .overlay(Color.white)
                            .padding(
                                [.leading, .trailing],
                                Constants.dividerPadding
                            )
                        
                        HStack {
                            Spacer()
                            Text("\(Localization.highestToday): \(model.maxValue)")
                            Spacer()
                        }
                    }
                    .font(
                        .custom(
                            FontFamily.Montserrat.regular,
                            size: Constants.defaultFontSize
                        )
                    )
                    .minimumScaleFactor(Constants.minScaleFactor)
                    .padding()
                }
            }
        }
    }
}

// MARK: - Preview
struct MinMaxGlucoseValuesWidget_Preview: PreviewProvider {
    static var previews: some View {
        MinMaxGlucoseValuesWidget(model: .init(minValue: "4", maxValue: "12"))
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultCornerRadius: CGFloat = 12
    static let defaultFontSize: CGFloat = 17
    static let minScaleFactor: CGFloat = 0.5
    static let defaultCircleWidthOrHeight: CGFloat = 15
    static let dividerPadding: CGFloat = 20
}
