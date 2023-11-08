//
//  ContentTypePlugin.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.04.2023.
//

import Foundation

final class JSONContentTypePlugin: NetworkPlugin {
    // MARK: - Public methods
    func modify(_ request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
