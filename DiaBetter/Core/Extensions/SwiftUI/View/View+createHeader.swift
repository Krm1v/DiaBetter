//
//  View+createHeader.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.10.2023.
//

import SwiftUI

extension View {
    func createHeader(with title: String) -> some View {
        HStack {
            Text(title)
                .font(
                    .custom(
                        FontFamily.Montserrat.semiBold,
                        size: Constants.defaultFontSize)
                )
            
            Spacer()
        }
        .padding(.bottom)
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultFontSize: CGFloat = 20
}
