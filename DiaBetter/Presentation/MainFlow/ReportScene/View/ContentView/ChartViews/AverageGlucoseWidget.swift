//
//  AverageGlucoseWidget.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.10.2023.
//

import SwiftUI

struct AverageGlucoseWidget: View {
    // MARK: - Properties
    @State var model: TodayAverageGlucoseChartModel
    
    // MARK: - Body
    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: Constants.defaultCornerRadius
            )
            .foregroundStyle(Color.white)
            .overlay {
                
                RoundedRectangle(
                    cornerRadius: Constants.defaultCornerRadius
                )
                .foregroundStyle(.black)
                .padding(1)
                .overlay {
                    ZStack {
                        VStack {
                            Text(Localization.averageGlucose)
                                .font(
                                    .custom(
                                        FontFamily.Montserrat.regular.name,
                                        size: Constants.defaultFontSize
                                    )
                                )
                                .minimumScaleFactor(Constants.minScaleFactor)
                            
                            HStack {
                                
                                Text("\(model.glucoseValue)  \(model.glucoseUnit)")
                                    .font(
                                        .custom(
                                            FontFamily.Montserrat.regular.name,
                                            size: Constants.defaultFontSize
                                        )
                                    )
                                
                                Circle()
                                    .fill(Color(uiColor: model.dotColor))
                                    .frame(
                                        width: Constants.defaultCircleWidthOrHeight,
                                        height: Constants.defaultCircleWidthOrHeight
                                    )
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct AverageGlucoseWidget_Preview: PreviewProvider {
    static var previews: some View {
        AverageGlucoseWidget(model: .init(glucoseValue: "123", glucoseUnit: "123"))
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultCornerRadius: CGFloat = 12
    static let defaultFontSize: CGFloat = 17
    static let minScaleFactor: CGFloat = 0.5
    static let defaultCircleWidthOrHeight: CGFloat = 15
}
