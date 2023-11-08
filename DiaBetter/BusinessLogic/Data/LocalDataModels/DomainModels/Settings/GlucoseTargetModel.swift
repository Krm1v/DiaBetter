//
//  GlucoseTargetModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.09.2023.
//

import Foundation

struct GlucoseTarget: Codable, Equatable {
    var min: Decimal
    var max: Decimal
}
