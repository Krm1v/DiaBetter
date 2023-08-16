//
//  RecordsNetworkService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine

protocol RecordsNetworkService {
	func addRecord(record: RecordRequestModel) -> AnyPublisher<RecordsResponseModel, NetworkError>
	func updateRecord(record: RecordRequestModel, id: String) -> AnyPublisher<RecordsResponseModel, NetworkError>
	func fetchRecords() -> AnyPublisher<[RecordsResponseModel], NetworkError>
	func deleteRecord(id: String) -> AnyPublisher<Void, NetworkError>
}

final class RecordsNetworkServiceImpl<NetworkProvider: NetworkServiceProvider> where NetworkProvider.EndpointType == RecordsEndpoint {
	//MARK: - Properties
	private let networkProvider: NetworkProvider
	
	//MARK: - Init
	init(_ networkProvider: NetworkProvider) {
		self.networkProvider = networkProvider
	}
}

//MARK: - Private extension
extension RecordsNetworkServiceImpl: RecordsNetworkService {
	func addRecord(record: RecordRequestModel) -> AnyPublisher<RecordsResponseModel, NetworkError> {
		return networkProvider.execute(endpoint: .addRecord(record), decodeType: RecordsResponseModel.self)
	}
	
	func updateRecord(record: RecordRequestModel, id: String) -> AnyPublisher<RecordsResponseModel, NetworkError> {
		return networkProvider.execute(endpoint: .updateRecord(record, id), decodeType: RecordsResponseModel.self)
	}
	
	func fetchRecords() -> AnyPublisher<[RecordsResponseModel], NetworkError> {
		return networkProvider.execute(endpoint: .fetchRecords, decodeType: [RecordsResponseModel].self)
	}
	
	func deleteRecord(id: String) -> AnyPublisher<Void, NetworkError> {
		return networkProvider.execute(endpoint: .deleteRecord(id))
	}
}

