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
	func save(records: [Record])
	func clear()
	func addRecord(record: Record) -> AnyPublisher<Record, Error>
	func updateRecord(record: Record, id: String) -> AnyPublisher<Record, Error>
	func fetchRecords(userId: String) -> AnyPublisher<[Record], Error>
	func deleteRecord(id: String) -> AnyPublisher<Void, Error>
	func deleteAllRecords(id: String) -> AnyPublisher<Void, Error>
	func uploadAllRecords(records: [Record]) -> AnyPublisher<[String], Error>
	func filterRecordsByDate(userId: String, startDate: Date, endDate: Date) -> AnyPublisher<[Record], Error>
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
	
	func save(records: [Record]) {
		let dataRecords = records.map { seriallize(record: $0) }
		saveToDefaults(value: dataRecords, for: .dataRecords)
		_ = records.map { recordSubject.send($0) }
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
		let recordRequestModel = createRequestModel(
			record,
			date: date.stringRepresentation(format: .monthDayYearTime,
											timeZone: TimeZone(identifier: "GMT") ?? .current)
		)
		return recordsNetworkService.addRecord(record: recordRequestModel)
			.mapError { $0 as Error }
			.map {
				let record = Record($0)
				self.save(record: record)
				return record
			}
			.eraseToAnyPublisher()
	}
	
	func uploadAllRecords(records: [Record]) -> AnyPublisher<[String], Error> {
		var recordsModel: [RecordRequestModel] = []
		
		for record in records {
			let recordRequestModel = createRequestModel(
				record,
				date: record.recordDate?.stringRepresentation(format: .monthDayYearTime)
			)
			recordsModel.append(recordRequestModel)
			debugPrint(record.recordDate?.stringRepresentation(format: .monthDayYearTime))
		}
		let chunkSize = 100
		let chunks: [[RecordRequestModel]] = stride(from: 0, to: recordsModel.count, by: chunkSize).map {
			Array(recordsModel[$0..<min($0 + chunkSize, recordsModel.count)])
		}
		
		return chunks
			.publisher
			.flatMap({ records -> AnyPublisher<[String], Error> in
				return self.recordsNetworkService.uploadRecords(records: records)
					.mapError { $0 as Error }
					.eraseToAnyPublisher()
			})
			.reduce([]) { acc, value in
				acc + value
			}
			.eraseToAnyPublisher()
	}
	
	func updateRecord(record: Record, id: String) -> AnyPublisher<Record, Error> {
		guard let date = record.recordDate else {
			return Fail(error: RecordServiceErrors.failToConvert)
				.eraseToAnyPublisher()
		}
		let recordRequestModel = createRequestModel(
			record,
			date: date.stringRepresentation(format: .monthDayYearTime,
											timeZone: TimeZone(identifier: "GMT") ?? .current)
		)
		return recordsNetworkService.updateRecord(record: recordRequestModel, id: record.objectId)
			.mapError { $0 as Error }
			.map(Record.init)
			.handleEvents(receiveOutput: { [weak self] response in
				guard let self = self else { return }
				self.save(record: response)
			})
			.eraseToAnyPublisher()
	}
	
	func fetchRecords(userId: String) -> AnyPublisher<[Record], Error> {
		return recordsNetworkService.fetchRecords(userId: userId)
			.mapError { $0 as Error }
			.map { $0.map(Record.init) }
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
	
	func deleteAllRecords(id: String) -> AnyPublisher<Void, Error> {
		return recordsNetworkService.deleteAllRecords(userId: id)
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}
	
	func filterRecordsByDate(userId: String, startDate: Date, endDate: Date) -> AnyPublisher<[Record], Error> {
		return recordsNetworkService.filterRecordsByDate(
			userId: userId,
			startDate: startDate.stringRepresentation(format: .monthDayYear, timeZone: TimeZone(identifier: "GMT") ?? .current),
			endDate: endDate.stringRepresentation(format: .monthDayYear, timeZone: TimeZone(identifier: "GMT") ?? .current)
		)
			.mapError { $0 as Error }
			.map { $0.map(Record.init) }
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
private extension RecordsService {
	func createRequestModel(_ record: Record, date: String?) -> RecordRequestModel {
		return RecordRequestModel(fastInsulin: record.fastInsulin,
								  longInsulin: record.longInsulin,
								  recordNote: record.recordNote,
								  glucoseLevel: record.glucoseLevel,
								  recordDate: date,
								  meal: record.meal,
								  ownerId: record.userId)
	}
}
