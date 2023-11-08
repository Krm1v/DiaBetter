//
//  AverageGlucoseCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.09.2023.
//

import SwiftUI

struct AverageGlucoseHomeWidget: View {
    // MARK: - Properties
    @State var model: AverageGlucoseChartModel
    
    // MARK: - Body
    var body: some View {
        borderedMainContent
    }
    
    // MARK: - MainContent
    private var mainContent: some View {
        VStack {
            VStack {
                HStack {
                    
                    Text(model.period.title)
                        .minimumScaleFactor(
                            Constants.minScaleFactor
                        )
                        .font(
                            .custom(
                                FontFamily.Montserrat.regular,
                                size: Constants.defaultFontSize
                            )
                        )
                        .lineLimit(Constants.defaultLineLimit)
                    
                    Spacer()
                    
                    Image(asset: Assets.dropFilled)
                        .renderingMode(.template)
                        .resizable()
                        .frame(
                            width: Constants.defaultImageEdge,
                            height: Constants.defaultImageEdge
                        )
                        .foregroundStyle(
                            Color(
                                uiColor: model.dotColor
                            )
                        )
                }
                .padding([.leading, .trailing])
                
                Divider()
                    .overlay(Color.white)
                    .frame(height: 1)
                    .padding([.leading, .trailing])
                
                Text(model.averageValue)
                
                Text(model.glucoseUnit.title)
            }
            .font(
                .custom(
                    FontFamily.Montserrat.semiBold,
                    size: Constants.smallFontSize
                )
            )
        }
    }
    
    // MARK: - Bordered container
    private var borderedMainContent: some View {
        RoundedRectangle(
            cornerRadius: Constants.defaultCornerRadius
        )
        .stroke(Color.white)
        .overlay {
            RoundedRectangle(
                cornerRadius: Constants.defaultCornerRadius
            )
            .fill(.black)
            .overlay {
                mainContent
            }
            .padding(1)
        }
    }
}

// MARK: - Preview
struct AverageGlucoseCell_Preview: PreviewProvider {
    static var previews: some View {
        AverageGlucoseHomeWidget(model: AverageGlucoseChartModel(
            averageValue: "10",
            glucoseUnit: .mmolL,
            dotColor: .red,
            period: .threeMonth))
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let minScaleFactor: CGFloat = 0.3
    static let defaultFontSize: CGFloat = 17
    static let defaultLineLimit: Int = 1
    static let defaultImageEdge: CGFloat = 15
    static let defaultCornerRadius: CGFloat = 12
    static let smallFontSize: CGFloat = 15
}
