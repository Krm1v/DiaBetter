//
//  SettingsService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 22.06.2023.
//

import Foundation
import Combine

protocol SettingsService: AnyObject {
	var settings: AppSettingsModel { get set }
	var settingsPublisher: AnyPublisher<AppSettingsModel, Never> { get }

	func save(settings: AppSettingsModel)
	func fetch() -> AppSettingsModel?
	func clear()
}

final class SettingsServiceImpl: SettingsService {
	// MARK: - Properties
	private let userDefaults: UserDefaultsManager
	private let dataConverter: DataConverter
	var settings: AppSettingsModel = AppSettingsModel() {
		didSet {
			settingsSubject.value = settings
		}
	}

	private(set) lazy var settingsPublisher = settingsSubject.eraseToAnyPublisher()
	private lazy var settingsSubject = CurrentValueSubject<AppSettingsModel, Never>(settings)

	// MARK: - Init
	init() {
		self.userDefaults = UserDefaultsManagerImpl<AppSettingsModel>()
		self.dataConverter = DataConverterImpl()
		guard let settingsData = fetch() else {
			return
		}

		settings = settingsData
		settingsSubject.send(settings)
	}

	// MARK: - Public methods
	func save(settings: AppSettingsModel) {
		guard let data = dataConverter.seriallizeToData(object: settings) else {
			return
		}
		userDefaults.save(data, for: .appSettings)
		settingsSubject.send(settings)
	}

	func fetch() -> AppSettingsModel? {
		guard let value: Data = userDefaults.fetch(for: .appSettings) else {
			return nil
		}
		guard let settings: AppSettingsModel? = dataConverter.deseriallizeFromData(data: value) else {
			return nil
		}
		return settings
	}

	func clear() {
		userDefaults.delete(.appSettings)
	}
}
