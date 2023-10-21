//
//  AverageGlucoseCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.09.2023.
//

import SwiftUI

struct AverageGlucoseHomeWidget: View {
    
    @State var model: AverageGlucoseChartModel
    
    var body: some View {
        borderedMainContent
            .padding()
    }
    
    private var mainContent: some View {
        VStack {
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: model.dotColor))
                    .padding(25)
                
                Text(model.period.title)
                    .font(
                        .custom(
                            FontFamily.Montserrat.regular,
                            size: 17))
                
                Divider()
                    .overlay(Color.white)
                    .frame(height: 1)
                    .padding([.leading, .trailing])
            }
            
            VStack {
                Text(model.averageValue)
                
                Text(model.glucoseUnit.title)
            }
            .font(
                .custom(
                    FontFamily.Montserrat.semiBold,
                    size: 15))
            .padding(.bottom)
            
            Spacer()
        }
    }
    
    private var borderedMainContent: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.white)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black)
                    .overlay {
                        mainContent
                    }
                    .padding(1)
            }
    }
}

struct AverageGlucoseCell_Preview: PreviewProvider {
    static var previews: some View {
        AverageGlucoseHomeWidget(model: AverageGlucoseChartModel(
            averageValue: "10",
            glucoseUnit: .mmolL,
            dotColor: .red,
            period: .threeMonth))
    }
}
