//
//  NetworkServiceProvider.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.02.2023.
//

import Foundation
import Combine

protocol NetworkServiceProvider {
    associatedtype EndpointType = Endpoint
    
    func execute(endpoint: EndpointType) -> AnyPublisher<Void, NetworkError>
    func execute<Model: Decodable>(endpoint: EndpointType, decodeType: Model.Type) -> AnyPublisher<Model, NetworkError>
}

final class NetworkServiceProviderImpl<E: Endpoint> {
    // MARK: - Properties
    private let baseURLStorage: BaseURLStorage
    private let networkManager: NetworkManager
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let plugins: [NetworkPlugin]
    
    // MARK: - Init
    init(
        baseURLStorage: BaseURLStorage,
        networkManager: NetworkManager,
        plugins: [NetworkPlugin] = [],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURLStorage = baseURLStorage
        self.networkManager = networkManager
        self.plugins = plugins
        self.encoder = encoder
        self.decoder = decoder
    }
}

// MARK: - Extension NetworkServiceProvider
extension NetworkServiceProviderImpl: NetworkServiceProvider {
    func execute(endpoint: E) -> AnyPublisher<Void, NetworkError> {
        guard let request = endpoint.buildRequest(
            baseURL: baseURLStorage.baseURL,
            encoder: encoder,
            plugins: plugins)
        else {
            return Fail(error: NetworkError.dataDecodingError)
                .eraseToAnyPublisher()
        }
        return networkManager.request(request: request)
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    func execute<Model>(
        endpoint: E,
        decodeType: Model.Type
    ) -> AnyPublisher<Model, NetworkError> where Model: Decodable {
        guard let request = endpoint.buildRequest(
            baseURL: baseURLStorage.baseURL,
            encoder: encoder,
            plugins: plugins)
        else {
            return Fail(error: NetworkError.requestError(.encodingError))
                .eraseToAnyPublisher()
        }
        return networkManager.request(request: request)
            .decode(type: decodeType, decoder: decoder)
            .mapError { error in
                if case let error as RequestBuilderError = error {
                    return NetworkError.requestError(error)
                }
                return NetworkError.unexpectedError
            }
            .eraseToAnyPublisher()
    }
}
