//
//  EmptyWidgetStateView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 12.10.2023.
//

import SwiftUI

struct EmptyWidgetStateView: View {
    
    @State var textMessage: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.white)
                .frame(height: UIScreen.main.bounds.width / 2)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.black)
                        .padding(1)
                }
            
            Text(textMessage)
                .font(.custom(FontFamily.Montserrat.regular, size: 17))
                .minimumScaleFactor(0.5)
                .padding()
        }
    }
}

struct EmptyWidgetStateView_Preview: PreviewProvider {
    static var previews: some View {
        EmptyWidgetStateView(textMessage: Localization.noDataAvailable)
    }
}
