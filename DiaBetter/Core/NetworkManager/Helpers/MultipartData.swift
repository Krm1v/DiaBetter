//
//  MultipartDataBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 14.03.2023.
//

import Foundation

struct MultipartBody {
	let boundary: String
	let multipartData: Data
	let lenght: Int

	static func buildMultipartBody(from items: [MultipartDataItem]) -> MultipartBody {
		let requestBody = NSMutableData()
		let lineBreak = "\r\n"
		let boundary = UUID().uuidString

		items.forEach { item in
			requestBody.append("\(lineBreak)--\(boundary + lineBreak)")
			requestBody.append("Content-Disposition: form-data; name=\"\(item.attachmentKey)\"")
			requestBody.append("; filename=\"\(item.fileName).jpeg\"\(lineBreak)")
			requestBody.append("Content-Type: \(item.mimeType.rawValue) \(lineBreak + lineBreak)")
			requestBody.append(item.data)
		}
		requestBody.append("\(lineBreak)--\(boundary)--\(lineBreak)")
		return .init(boundary: boundary, multipartData: requestBody as Data, lenght: requestBody.count)
	}
}

struct MultipartDataItem {
	 enum MultipartDataMimeType: String {
		case pngImage = "image/png"
		case jpegImage = "image/jpeg"
		case plainText = "text/plain"
		case defaultType = "file"
	}

	let data: Data
	let attachmentKey: String
	let fileName: String
	var mimeType: MultipartDataMimeType = .defaultType
}
