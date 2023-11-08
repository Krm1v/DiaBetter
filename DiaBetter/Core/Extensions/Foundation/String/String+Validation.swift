//
//  String+EmailValidation.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 30.05.2023.
//

import Foundation

extension String {
    static func useRegex(_ regex: RegularExpressions) -> String {
        return regex.rawValue
    }
    
    func validate(with regex: RegularExpressions) -> Bool {
        let predicate = NSPredicate(
            format: "SELF MATCHES %@",
            type(of: self).useRegex(regex))
        return predicate.evaluate(with: self)
    }
}
