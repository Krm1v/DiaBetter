//
//  Double+String.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 31.10.2023.
//

import Foundation

extension Double {
    func convertToString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.decimalSeparator = "."
        
        return numberFormatter.string(from: self as NSNumber) ?? ""
    }
}
