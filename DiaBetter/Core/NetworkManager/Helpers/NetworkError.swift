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
		case .encodingError: 	return "Error occured during data encoding."
		case .badURL: 			return "Bad URL error occured."
		case .badURLComponents: return "Bad URL components error occured."
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
}

extension NetworkError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .clientError(let data):
			let defaultErrorMessage = "An error occured on the client side. Please, try again later"
			guard let data = data,
				  let errorModel = try? JSONDecoder().decode(APIErrorResponseModel.self, from: data)
			else {
				return defaultErrorMessage
			}
			return errorModel.message

		case .serverError:
			return "An error occured on the client side. Please, try again later"
		case .dataDecodingError:
			return "An error occured during data decoding. Please, try again later."
		case .unexpectedError:
			return "Oops! Something went wrong. Unexpected error occured. Please, try again later."
		case .badURLError:
			return "Bad URL error occured. Please, try again later."
		case .timeOutError:
			return "Timeout error occured. Check your Internet connection or try again later."
		case .hostError:
			return "Host error occured. Please, try again later."
		case .redirectError:
			return "Redirect error occured. Please, try again later."
		case .resourceUnavailable:
			return "The resource is currently unavailable. Please, try again later."
		case .tokenError:
			return "Token error occured. Please, try again later."
		case .requestError(let error):
			return error.requestErrorDescription
		case .noResponse:
			return "There are no response from the server. Please, try again later."
		}
	}
}
