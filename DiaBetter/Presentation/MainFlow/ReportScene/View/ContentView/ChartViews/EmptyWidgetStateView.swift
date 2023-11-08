//
//  EmptyWidgetStateView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 12.10.2023.
//

import SwiftUI

struct EmptyWidgetStateView: View {
    // MARK: - Properties
    @State var textMessage: String = Localization.noDataAvailable
    
    // MARK: - Body
    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: Constants.defaultCornerRadius
            )
            .foregroundStyle(
                Color(
                    uiColor: Colors.darkNavyBlue.color
                )
            )
            .background(.ultraThinMaterial)
            .opacity(Constants.defaultOpacity)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Constants.defaultCornerRadius,
                    style: .continuous
                )
            )
            
            Text(textMessage)
                .font(
                    .custom(
                        FontFamily.Montserrat.regular,
                        size: Constants.defaultFontSize
                    )
                )
                .minimumScaleFactor(Constants.defaultScaleFactor)
                .padding()
                .background(
                    Color(
                        uiColor: Colors.darkNavyBlue.color
                    )
                )
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(
                        cornerRadius: Constants.defaultCornerRadius
                    )
                )
        }
    }
}

// MARK: - Previews
struct EmptyWidgetStateView_Preview: PreviewProvider {
    static var previews: some View {
        EmptyWidgetStateView(textMessage: Localization.noDataAvailable)
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultCornerRadius: CGFloat = 12
    static let defaultFontSize: CGFloat = 17
    static let defaultOpacity: CGFloat = 0.4
    static let defaultScaleFactor: CGFloat = 0.5
}
