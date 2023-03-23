//
//  Endpoint.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.02.2023.
//

import Foundation

enum RequestBody {
	case rawData(Data)
	case encodable(Encodable)
	case multipartData([MultipartDataItem])
}

typealias HTTPQueries = [String: String]
typealias HTTPHeaders = [String: String]

protocol Endpoint: RequestBuilder {
	var baseURL: URL? { get }
	var path: String? { get }
	var httpMethod: HTTPMethods { get }
	var queries: HTTPQueries { get }
	var headers: HTTPHeaders { get }
	var body: RequestBody? { get }
}

protocol RequestBuilder {
	func buildRequest(baseURL: URL, encoder: JSONEncoder) -> URLRequest?
}

//MARK: - Endpoint Extension
extension Endpoint {
	//MARK: - Properties
	var baseURL: URL? { return nil }
	
	//MARK: - Methods
	func buildRequest(baseURL: URL, encoder: JSONEncoder) -> URLRequest? {
		var completedURL = self.baseURL ?? baseURL
		guard let path = path else { return nil }
		completedURL = completedURL.appendingPathComponent(path)
		guard var components = URLComponents(url: completedURL,
											 resolvingAgainstBaseURL: true) else { return nil }
		components.queryItems = queries.map { item in
			URLQueryItem(name: item.key, value: item.value)
		}
		guard let urlForRequest = components.url else { return nil }
		var urlRequest = URLRequest(url: urlForRequest)
		urlRequest.httpMethod = httpMethod.rawValue
		if let body = body {
			switch body {
			case let .rawData(data):
				urlRequest.httpBody = data
			case let .encodable(dataModel):
				guard let data = try? encoder.encode(dataModel) else { return nil }
				urlRequest.httpBody = data
			case let .multipartData(items):
				let multipartBody = MultipartBody.buildMultipartBody(from: items)
				urlRequest.httpBody = multipartBody.multipartData
				urlRequest.addValue("multipart/form-data; boundary=\(multipartBody.boundary)",
									forHTTPHeaderField: "Content-Type")
				urlRequest.addValue("\(multipartBody.lenght)", forHTTPHeaderField: "Content-Lenght")
			}
		}
		headers.forEach { (key: String, value: String) in
			urlRequest.addValue(value, forHTTPHeaderField: key)
		}
		return urlRequest
	}
}
