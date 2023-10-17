//
//  MinMaxGlucoseValuesWidget.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.10.2023.
//

import SwiftUI

struct MinMaxGlucoseValuesWidget: View {
    
    @State var model: TodayMinMaxGlucoseValuesChartModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black)
                        .padding(1)
                        .overlay {
                            VStack {
                                
                                HStack {
                                    Spacer()
                                    Text("Lowest today: \(model.minValue)")
                                    Spacer()
                                }
                                
                                Divider()
                                    .frame(height: 1)
                                    .overlay(Color.white)
                                    .padding([.leading, .trailing], 20)
                                
                                HStack {
                                    Spacer()
                                    Text("Highest today: \(model.maxValue)")
                                    Spacer()
                                }
                            }
                            .font(.custom(FontFamily.Montserrat.regular, size: 17))
                            .minimumScaleFactor(0.5)
                            .padding()
                        }
                }
        }
    }
}

struct MinMaxGlucoseValuesWidget_Preview: PreviewProvider {
    static var previews: some View {
        MinMaxGlucoseValuesWidget(model: .init(minValue: "4", maxValue: "12"))
    }
}
