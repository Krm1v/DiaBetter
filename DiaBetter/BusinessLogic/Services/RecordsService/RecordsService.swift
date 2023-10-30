//
//  RecordsService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine

protocol RecordsService {
    var records: [Record] { get set }
    var recordsPublisher: AnyPublisher<[Record], Never> { get }
    
    func save(records: [Record])
    func clear()
    func addRecord(record: Record) -> AnyPublisher<Record, Error>
    func updateRecord(record: Record, id: String) -> AnyPublisher<Record, Error>
    func fetchRecords(userId: String) -> AnyPublisher<[Record], Error>
    func deleteRecord(id: String) -> AnyPublisher<Void, Error>
    func deleteAllRecords(id: String) -> AnyPublisher<Void, Error>
    func uploadAllRecords(records: [Record]) -> AnyPublisher<[String], Error>
    func filterRecordsByDate(userId: String, startDate: Date, endDate: Date) -> AnyPublisher<[Record], Error>
    func fetchPaginatedRecords(userId: String, pageSize: Int, offset: Int) -> AnyPublisher<[Record], Error>
}

final class RecordsServiceImpl {
    // MARK: - Properties
    private let recordsNetworkService: RecordsNetworkService
    private let tokenStorage: TokenStorage
    private let recordsSubject = CurrentValueSubject<[Record], Never>([])
    private(set) lazy var recordsPublisher = recordsSubject.eraseToAnyPublisher()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(recordsNetworkService: RecordsNetworkService, tokenStorage: TokenStorage) {
        self.recordsNetworkService = recordsNetworkService
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Public methods
    func save(records: [Record]) {
        self.records = records
        recordsSubject.send(records)
    }
    
    func clear() {
        records = []
        recordsSubject.send(records)
    }
    
    // MARK: - Network requests
    func addRecord(record: Record) -> AnyPublisher<Record, Error> {
        return recordsNetworkService.addRecord(record: createRequestModel(record))
            .mapError { $0 as Error }
            .map { Record($0) }
            .handleEvents(receiveOutput: { [weak self] record in
                guard let self = self else {
                    return
                }
                self.records.append(record)
            })
            .eraseToAnyPublisher()
    }
    
    func uploadAllRecords(records: [Record]) -> AnyPublisher<[String], Error> {
        let recordsModel = createBackupSource(from: records)
        
        let chunkSize = 100
        let chunks = stride(
            from: 0,
            to: recordsModel.count,
            by: chunkSize)
            .map {
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
        return recordsNetworkService.updateRecord(record: createRequestModel(record), id: id)
            .mapError { $0 as Error }
            .map(Record.init)
            .handleEvents(receiveOutput: { [weak self] record in
                guard let self = self else {
                    return
                }
                if let index = records.firstIndex(where: { $0.objectId == record.objectId }) {
                    records[index] = record
                }
            })
            .eraseToAnyPublisher()
    }
    
    func fetchRecords(userId: String) -> AnyPublisher<[Record], Error> {
        return recordsNetworkService.fetchRecords(userId: userId)
            .mapError { $0 as Error }
            .map { $0.map(Record.init) }
            .handleEvents(receiveOutput: { [weak self] records in
                guard let self = self else {
                    return
                }
                self.save(records: records)
            })
            .eraseToAnyPublisher()
    }
    
    func deleteRecord(id: String) -> AnyPublisher<Void, Error> {
        return recordsNetworkService.deleteRecord(id: id)
            .mapError { $0 as Error }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self else {
                    return
                }
                if let index = records.firstIndex(where: { $0.objectId == id }) {
                    records.remove(at: index)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func deleteAllRecords(id: String) -> AnyPublisher<Void, Error> {
        return recordsNetworkService.deleteAllRecords(userId: id)
            .mapError { $0 as Error }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.clear()
            })
            .eraseToAnyPublisher()
    }
    
    func filterRecordsByDate(
        userId: String,
        startDate: Date,
        endDate: Date
    ) -> AnyPublisher<[Record], Error> {
        return recordsNetworkService.filterRecordsByDate(
            userId: userId,
            startDate: startDate.timeIntervalSince1970 * 1000,
            endDate: endDate.timeIntervalSince1970 * 1000
        )
        .mapError { $0 as Error }
        .map { $0.map(Record.init) }
        .eraseToAnyPublisher()
    }
    
    func fetchPaginatedRecords(
        userId: String,
        pageSize: Int,
        offset: Int
    ) -> AnyPublisher<[Record], Error> {
        recordsNetworkService.fetchPaginatedRecords(
            userId: userId,
            pageSize: String(pageSize),
            offset: String(offset))
        .mapError { $0 as Error }
        .map { $0.map(Record.init) }
        .eraseToAnyPublisher()
    }
}

// MARK: - Extension UserService
extension RecordsServiceImpl: RecordsService {
    var records: [Record] {
        get {
            recordsSubject.value
        }
        set {
            recordsSubject.value = newValue
        }
    }
}

// MARK: - Private extension
private extension RecordsServiceImpl {
    func createRequestModel(_ record: Record) -> RecordRequestModel {
        let timeInterval = record.recordDate.timeIntervalSince1970 * 1000
        return RecordRequestModel(
            recordId: record.recordId,
            fastInsulin: record.fastInsulin,
            longInsulin: record.longInsulin,
            recordNote: record.recordNote,
            glucoseLevel: record.glucoseLevel,
            recordDate: timeInterval,
            meal: record.meal,
            ownerId: record.userId)
    }
    
    func createBackupSource(from records: [Record]) -> [RecordRequestModel] {
        var recordsModel: [RecordRequestModel] = []
        
        if !self.records.isEmpty {
            let existingIds = Set(self.records.map { $0.recordId })
            
            let uniqueRecords = records.filter { !existingIds.contains($0.recordId) }
            
            recordsModel = uniqueRecords.map { createRequestModel($0) }
        } else {
            recordsModel = records.map { createRequestModel($0) }
        }
        return recordsModel
    }
}
