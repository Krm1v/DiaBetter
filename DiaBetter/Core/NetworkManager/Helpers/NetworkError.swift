//
//  NeetworkErrors.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.02.2023.
//

import Foundation

enum RequestBuilderError: Error {
    case encodingError
    case badURL
    case badURLComponents
}

extension RequestBuilderError: LocalizedError {
    var requestErrorDescription: String? {
        switch self {
        case .encodingError: 	return Localization.encodingErrorMessage
        case .badURL: 			return Localization.badUrlError
        case .badURLComponents: return Localization.urlComponentsErrorMessage
        }
    }
}

enum NetworkError: Error {
    case clientError(Data?)
    case serverError
    case dataDecodingError
    case unexpectedError
    case badURLError
    case timeOutError
    case hostError
    case redirectError
    case resourceUnavailable
    case tokenError
    case requestError(RequestBuilderError)
    case noResponse
    
    // MARK: - Properties
    var decoder: JSONDecoder {
        JSONDecoder()
    }
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .clientError(let data):
            let defaultErrorMessage = Localization.defaultErrorMessage
            guard let data = data,
                  let errorModel = try? decoder.decode(
                    APIErrorResponseModel.self,
                    from: data)
            else {
                return defaultErrorMessage
            }
            return errorModel.message
            
        case .serverError:
            return Localization.serverErrorMessage
        case .dataDecodingError:
            return Localization.dataDecodingErrorMessage
        case .unexpectedError:
            return Localization.unexpectedErrorMessage
        case .badURLError:
            return Localization.badUrlMessage
        case .timeOutError:
            return Localization.timeoutErrorMessage
        case .hostError:
            return Localization.hostErrorMessage
        case .redirectError:
            return Localization.redirectErrorMessage
        case .resourceUnavailable:
            return Localization.resourceUnavailableError
        case .tokenError:
            return Localization.tokenErrorMessage
        case .requestError(let error):
            return error.requestErrorDescription
        case .noResponse:
            return Localization.noResponseErrorMessage
        }
    }
}
