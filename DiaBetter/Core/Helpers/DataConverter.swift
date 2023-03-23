//
//  DataConverter.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 02.03.2023.
//

import Foundation

protocol DataConverter {
	func seriallizeToData<T: Encodable>(object: T) -> Data?
	func deseriallizeFromData<T: Decodable>(data: Data?) -> T?
}

final class DataConverterImpl {
	//MARK: - Properties
	private let encoder: JSONEncoder
	private let decoder: JSONDecoder
	
	//MARK: - Init
	init(encoder: JSONEncoder = JSONEncoder(),
		 decoder: JSONDecoder = JSONDecoder()) {
		self.encoder = encoder
		self.decoder = decoder
	}
}

//MARK: - Extension DataConverter
extension DataConverterImpl: DataConverter {
	func seriallizeToData<T: Encodable>(object: T) -> Data? {
		var encodedObject: Data?
		do {
			encodedObject = try encoder.encode(object)
		} catch let error {
			debugPrint(error.localizedDescription)
		}
		return encodedObject
	}
	
	func deseriallizeFromData<T: Decodable>(data: Data?) -> T? {
		var decodedObject: T?
		do {
			guard let data = data else { return nil }
			decodedObject = try decoder.decode(T.self, from: data)
		} catch let error {
			debugPrint(error.localizedDescription)
		}
		return decodedObject
	}
}
