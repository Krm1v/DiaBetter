//
//  NetworkManager.swift
//  CombineNetworkManagerTest
//
//  Created by Владислав Баранкевич on 12.02.2023.
//

import Foundation
import Combine

protocol Requestable: AnyObject {
	func request(request: URLRequest) -> AnyPublisher<Data, NetworkError>
}

final class NetworkManager: Requestable {
	// MARK: - Properties
	private let session: URLSession

	// MARK: - Init
	init(session: URLSession = .shared ) {
		self.session = session
	}

	// MARK: - Methods
	func request(request: URLRequest) -> AnyPublisher<Data, NetworkError> {
		return session
			.dataTaskPublisher(for: request)
			.mapError { [weak self] error -> NetworkError in
				guard let self = self else {
					return NetworkError.unexpectedError
				}
				Logger.error(String(describing: error))
				return convertError(error as NSError)
			}
			.flatMap { [weak self] output -> AnyPublisher<Data, NetworkError> in
				guard let self = self else {
					return Fail(error: NetworkError.unexpectedError)
						.eraseToAnyPublisher()
				}
				guard let response = output.response as? HTTPURLResponse else {
					return Fail(error: NetworkError.noResponse)
						.eraseToAnyPublisher()
				}
				Logger.info(response.statusCode.description)
//				Logger.log(output)
				Logger.info(response.url!.absoluteString)
				return self.handleError(output)
			}
			.eraseToAnyPublisher()
	}
}

// MARK: - Private extension
private extension NetworkManager {
	func handleError(_ output: URLSession.DataTaskPublisher.Output) -> AnyPublisher<Data, NetworkError> {
		guard let httpResponse = output.response as? HTTPURLResponse else {
			assert(false, "Response fail")
		}

		switch httpResponse.statusCode {
		case 200...399:
			return Just(output.data)
				.setFailureType(to: NetworkError.self)
				.eraseToAnyPublisher()
		case 400...499:
			return Fail(error: NetworkError.clientError(output.data))
				.eraseToAnyPublisher()
		case 500...599:
			return Fail(error: NetworkError.serverError)
				.eraseToAnyPublisher()
		default:
			return Fail(error: NetworkError.unexpectedError)
				.eraseToAnyPublisher()
		}
	}

	func convertError(_ error: NSError) -> NetworkError {
		switch error.code {
		case NSURLErrorBadURL:
			return .badURLError
		case NSURLErrorTimedOut:
			return .timeOutError
		case NSURLErrorCannotFindHost:
			return .hostError
		case NSURLErrorCannotConnectToHost:
			return .hostError
		case NSURLErrorHTTPTooManyRedirects:
			return .redirectError
		case NSURLErrorResourceUnavailable:
			return .resourceUnavailable
		default: return .unexpectedError
		}
	}
}
