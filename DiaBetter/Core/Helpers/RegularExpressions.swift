//
//  RegularExpressions.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 30.05.2023.
//

import Foundation

enum RegularExpressions: String {
    case emailValidator = #"^[^!-/\[{~]*(?:[0-9A-Za-z](?:[0-9A-Za-z]+|(\.)(?!\1)))*([^!/\[{~]){1,256}@[a-zA-Z0-9][a-zA-Z0-9-]{0,64}(?:\.[a-zA-Z0-9][a-zA-Z0-9-]{0,25})+"#
    case passwordValidator = #"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"#
    case recordValidation = "[0-9,]"
}
