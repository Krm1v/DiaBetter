//
//  RecordsNetworkService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine

protocol RecordsNetworkService {
	func addRecord(record: RecordRequestModel, userToken: String) -> AnyPublisher<RecordsResponseModel, NetworkError>
	func updateRecord(record: RecordRequestModel, objectId: String, userToken: String) -> AnyPublisher<RecordsResponseModel, NetworkError>
	func fetchRecords(userToken: String) -> AnyPublisher<[RecordsResponseModel], NetworkError>
	func deleteRecord(userToken: String, at objectId: String) -> AnyPublisher<Void, NetworkError>
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
	func addRecord(record: RecordRequestModel, userToken: String) -> AnyPublisher<RecordsResponseModel, NetworkError> {
		return networkProvider.execute(endpoint: .addRecord(record, userToken), decodeType: RecordsResponseModel.self)
	}
	
	func updateRecord(record: RecordRequestModel, objectId: String, userToken: String) -> AnyPublisher<RecordsResponseModel, NetworkError> {
		return networkProvider.execute(endpoint: .updateRecord(recordModel: record, userToken: userToken, objectId: objectId), decodeType: RecordsResponseModel.self)
	}
	
	func fetchRecords(userToken: String) -> AnyPublisher<[RecordsResponseModel], NetworkError> {
		return networkProvider.execute(endpoint: .fetchRecords(userToken), decodeType: [RecordsResponseModel].self)
	}
	
	func deleteRecord(userToken: String, at objectId: String) -> AnyPublisher<Void, NetworkError> {
		return networkProvider.execute(endpoint: .deleteRecord(userToken))
	}
}

