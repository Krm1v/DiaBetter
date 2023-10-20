//
//  AverageGlucoseWidget.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.10.2023.
//

import SwiftUI

struct AverageGlucoseWidget: View {
    
    @State var model: TodayAverageGlucoseChartModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.white)
                .overlay {
                    
                    RoundedRectangle.init(cornerRadius: 12)
                        .foregroundStyle(.black)
                        .padding(1)
                        .overlay {
                            ZStack {
                                VStack {
                                    HStack {
                                        
                                        Text(Localization.averageGlucose)
                                            .font(.custom(FontFamily.Montserrat.regular.name, size: 17))
                                            .minimumScaleFactor(0.5)
                                            .padding(.leading, 8)
                                        
                                        Circle()
                                            .fill(Color(uiColor: model.dotColor))
                                            .frame(width: 15, height: 15)
                                            .padding(.trailing, 8)
                                    }
                                    .padding(.bottom, 8)
                                    
                                    Text("\(model.glucoseValue)  \(model.glucoseUnit)")
                                        .font(.custom(FontFamily.Montserrat.regular.name, size: 17))
                                }
                            }
                        }
                }
        }
    }
}

struct AverageGlucoseWidget_Preview: PreviewProvider {
    static var previews: some View {
        AverageGlucoseWidget(model: .init(glucoseValue: "123", glucoseUnit: "123"))
    }
}
