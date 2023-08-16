//
//  RecordsService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine

enum RecordServiceErrors: Error {
	case missingRemoteId
	case failToConvert
}

protocol RecordsService {
	var record: Record? { get }
	var recordPublisher: AnyPublisher<Record?, Never> { get }
	
	func save(record: Record)
	func clear()
	func addRecord(record: Record) -> AnyPublisher<Record, Error>
	func updateRecord(record: Record, id: String) -> AnyPublisher<Record, Error>
	func fetchRecords() -> AnyPublisher<[Record], Error>
	func deleteRecord(id: String) -> AnyPublisher<Void, Error>
}

final class RecordsServiceImpl {
	//MARK: - Properties
	private let recordsNetworkService: RecordsNetworkService
	private let userDefaults: UserDefaultsManager
	private let dataConverter: DataConverter
	private let tokenStorage: TokenStorage
	private let recordSubject = CurrentValueSubject<Record?, Never>(nil)
	private(set) lazy var recordPublisher = recordSubject.eraseToAnyPublisher()
	private var cancellables = Set<AnyCancellable>()
	
	//MARK: - Init
	init(recordsNetworkService: RecordsNetworkService, tokenStorage: TokenStorage) {
		self.recordsNetworkService = recordsNetworkService
		self.tokenStorage = tokenStorage
		self.userDefaults = UserDefaultsManagerImpl<Record>()
		self.dataConverter = DataConverterImpl()
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
	
	//MARK: - Network requests
	func addRecord(record: Record) -> AnyPublisher<Record, Error> {
		guard let date = record.recordDate else {
			return Fail(error: RecordServiceErrors.failToConvert)
				.eraseToAnyPublisher()
		}
		let recordDate = transformIntToTimeInterval(date: date)
		let createRecordRequest = RecordRequestModel(fastInsulin: record.fastInsulin,
													 recordType: record.recordType,
													 longInsulin: record.longInsulin,
													 recordNote: record.recordNote,
													 glucoseLevel: record.glucoseLevel,
													 meal: record.meal,
													 recordDate: recordDate.convertDateToString(format: .monthDayYearTime))
		return recordsNetworkService.addRecord(record: createRecordRequest)
			.mapError { $0 as Error }
			.map {
				let record = Record($0)
				self.save(record: record)
				return record
			}
			.eraseToAnyPublisher()
	}
	
	func updateRecord(record: Record, id: String) -> AnyPublisher<Record, Error> {
		let recordUpdateRequest = RecordRequestModel(fastInsulin: record.fastInsulin,
													 recordType: record.recordType,
													 longInsulin: record.longInsulin,
													 recordNote: record.recordNote,
													 glucoseLevel: record.glucoseLevel,
													 meal: record.meal,
													 recordDate: nil)
		guard let recordId = record.objectId else {
			return Fail(error: RecordServiceErrors.missingRemoteId)
				.eraseToAnyPublisher()
		}
		return recordsNetworkService.updateRecord(record: recordUpdateRequest, id: recordId)
			.mapError { $0 as Error }
			.map(Record.init)
			.handleEvents(receiveOutput: { [weak self] response in
				guard let self = self else { return }
				self.save(record: response)
			})
			.eraseToAnyPublisher()
	}
	
	func fetchRecords() -> AnyPublisher<[Record], Error> {
		return recordsNetworkService.fetchRecords()
			.mapError { $0 as Error }
			.map({ $0.map(Record.init) })
			.eraseToAnyPublisher()
	}
	
	func deleteRecord(id: String) -> AnyPublisher<Void, Error> {
		guard let recordId = record?.objectId else {
			return Fail(error: RecordServiceErrors.missingRemoteId)
				.eraseToAnyPublisher()
		}
		return recordsNetworkService.deleteRecord(id: recordId)
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
}

//MARK: - Extension UserService
extension RecordsServiceImpl: RecordsService {
	var record: Record? {
		recordSubject.value
	}
}

//MARK: - Private extension
private extension RecordsServiceImpl {
	func transformIntToTimeInterval(date: Int) -> TimeInterval {
		return TimeInterval(date)
	}
}
