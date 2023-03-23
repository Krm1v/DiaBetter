//
//  UserDefaultsManager.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 27.02.2023.
//

import Foundation

enum UserDefaultsKeys: String {
	case dataUser
	case dataRecord
}

protocol UserDefaultsManager {
	func fetch<T>(for key: UserDefaultsKeys) -> T?
	func save<T>(_ value: T, for key: UserDefaultsKeys)
	func delete(_ key: UserDefaultsKeys)
}

final class UserDefaultsManagerImpl<T> {
	//MARK: - Properties
	private let defaults: UserDefaults
	
	//MARK: - Init
	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
	}
}

//MARK: - Private extension
extension UserDefaultsManagerImpl: UserDefaultsManager {
	func fetch<T>(for key: UserDefaultsKeys) -> T? {
		let object = defaults.object(forKey: key.rawValue) as? T
		defaults.synchronize()
		return object
	}
	
	func save<T>(_ value: T, for key: UserDefaultsKeys) {
		defaults.set(value, forKey: key.rawValue)
		defaults.synchronize()
	}
	
	func delete(_ key: UserDefaultsKeys) {
		defaults.removeObject(forKey: key.rawValue)
	}
}

