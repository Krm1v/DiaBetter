//
//  NetworkManager.swift
//  CombineNetworkManagerTest
//
//  Created by Владислав Баранкевич on 12.02.2023.
//

import Foundation
import Combine

fileprivate enum ErrorsDescriptions {
	static let invalidUrl = "Invalid URL"
	static let serverError = "Server error"
	static let noResponse = "No response from server"
	static let apiError = "API error happened"
	static let badRequest = "Bad request"
	static let unauthorized = "Unauthorized"
	static let notFound = "Resourse not found"
}

protocol Requestable: AnyObject {
	func request(request: URLRequest) -> AnyPublisher<Data, NetworkError>
}

final class NetworkManager: Requestable {
	//MARK: - Properties
	private let session: URLSession
	
	//MARK: - Init
	init(session: URLSession = .shared ) {
		self.session = session
	}
	
	//MARK: - Methods
	func request(request: URLRequest) -> AnyPublisher<Data, NetworkError> {
		return session
			.dataTaskPublisher(for: request)
			.mapError { error in
				Logger.error(String(describing: error))
				return NetworkError.invalidJSON(error.localizedDescription)
			}
			.flatMap { output -> AnyPublisher<Data, NetworkError> in
				guard let response = output.response as? HTTPURLResponse else {
					return Fail(error: NetworkError.noResponse(ErrorsDescriptions.noResponse))
						.eraseToAnyPublisher()
				}
				Logger.info(response.statusCode.description)
				Logger.info(response.description)
				switch response.statusCode {
				case 200...399:
					return Just(output.data)
						.setFailureType(to: NetworkError.self)
						.eraseToAnyPublisher()
				default:
					return Fail(error: NetworkError.noResponse(ErrorsDescriptions.noResponse))
						.eraseToAnyPublisher()
				}
			}
			.eraseToAnyPublisher()
	}
}
