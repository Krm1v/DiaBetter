//
//  TokenStorage.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.04.2023.
//

import Foundation
import KeychainAccess

protocol TokenStorage {
	var token: Token? { get }

	func save(token: Token)
	func clear()
}

final class TokenStorageImpl {
	// MARK: - Properties
	private let keychain: Keychain
	var token: Token?

	// MARK: - Init
	init(keychain: Keychain) {
		self.keychain = keychain

		if let tokenValue = keychain[Keys.token] {
			self.token = Token(value: tokenValue)
		}
	}
}

// MARK: - Extension TokenStorageImpl
extension TokenStorageImpl: TokenStorage {
	func save(token: Token) {
		self.token = token
		keychain[Keys.token] = token.value
	}

	func clear() {
		self.token = nil
		keychain[Keys.token] = nil
	}
}

// MARK: - Keys
private extension TokenStorageImpl {
	enum Keys: CaseIterable {
		static let token = "secure_token_key"
		static let email = "secure_email_key"
		static let name = "secure_name_key"
		static let userId = "secure_userId_key"
	}
}
