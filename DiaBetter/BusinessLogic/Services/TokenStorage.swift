//
//  TokenStorage.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.04.2023.
//

import Foundation

protocol TokenStorage {
	var token: Token? { get }
}

struct Token {
	let value: String
}
