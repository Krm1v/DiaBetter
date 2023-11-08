//
//  TokenPlugin.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.04.2023.
//

import Foundation

protocol NetworkPlugin: AnyObject {
    func modify(_ request: inout URLRequest)
}

final class TokenPlugin: NetworkPlugin {
    // MARK: - Propertirs
    let tokenStorage: TokenStorage
    
    // MARK: - Init
    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Public methods
    func modify(_ request: inout URLRequest) {
        if let token = tokenStorage.token?.value {
            request.addValue(token, forHTTPHeaderField: "user-token")
        }
    }
}
