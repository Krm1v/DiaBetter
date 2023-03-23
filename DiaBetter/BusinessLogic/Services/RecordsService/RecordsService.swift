//
//  RecordsService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine
import KeychainAccess

protocol RecordsService {
	var record: Record? { get }
	var recordPublisher: AnyPublisher<Record?, Never> { get }
	var token: String? { get }
	
	func save(record: Record)
	func clear()
	func convertDateToString(fromTimeStamp timestamp: TimeInterval) -> String
}

final class RecordsServiceImpl {
	//MARK: - Properties
	private let userDefaults: UserDefaultsManager
	private let dataConverter: DataConverter
	private let dateFormatManager: DateFormatManager
	private let configuration: AppConfiguration
	private let recordSubject = CurrentValueSubject<Record?, Never>(nil)
	private(set) lazy var recordPublisher = recordSubject.eraseToAnyPublisher()
	private let keychain: Keychain
	
	//MARK: - Init
	init(configuration: AppConfiguration) {
		self.configuration = configuration
		self.userDefaults = UserDefaultsManagerImpl<Record>()
		self.dataConverter = DataConverterImpl()
		self.dateFormatManager = DateFormatManagerImpl()
		self.keychain = Keychain(service: configuration.bundleId)
		guard let recordData: Data = fetchFromDefaults(for: .dataRecord) else { return }
		let record = deseriallize(from: recordData)
		recordSubject.send(record)
	}
	
	//MARK: - Public methods
	func save(record: Record) {
		let dataRecord = seriallize(record: record)
		saveToDefaults(value: dataRecord, for: .dataRecord)
		recordSubject.send(record)
	}
	
	func clear() {
		deleteFromDefaults(for: .dataUser)
		recordSubject.send(record)
	}
	
	func saveToDefaults<T>(value: T, for key: UserDefaultsKeys) {
		userDefaults.save(value, for: key)
	}
	
	func fetchFromDefaults<T>(for key: UserDefaultsKeys) -> T? {
		let value: T? = userDefaults.fetch(for: key)
		return value
	}
	
	func deleteFromDefaults(for key: UserDefaultsKeys) {
		userDefaults.delete(key)
	}
	
	func seriallize(record: Record) -> Data? {
		let dataRecord = dataConverter.seriallizeToData(object: record)
		return dataRecord
	}
	
	func deseriallize(from data: Data) -> Record? {
		let record: Record? = dataConverter.deseriallizeFromData(data: data)
		return record
	}
	
	func convertDateToString(fromTimeStamp timestamp: TimeInterval) -> String {
		return dateFormatManager.convertDateToString(fromTimeStamp: timestamp, format: .monthDayYearTime)
	}
}

//MARK: - Extension UserService
extension RecordsServiceImpl: RecordsService {
	var token: String? {
		keychain[Keys.token]
	}
	
	var record: Record? {
		recordSubject.value
	}
}

//MARK: - Extension Keys
extension RecordsServiceImpl {
	private enum Keys: CaseIterable {
		static let token = "secure_token_key"
		static let email = "secure_email_key"
		static let name = "secure_name_key"
		static let userId = "secure_userId_key"
	}
}

