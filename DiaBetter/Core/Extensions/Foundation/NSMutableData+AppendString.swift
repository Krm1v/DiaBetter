//
//  Data+AppendString.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 14.03.2023.
//

import Foundation

extension NSMutableData {
	func append(_ string: String, encoding: String.Encoding = .utf8) {
		guard let data = string.data(using: encoding) else {
			return
		}
		append(data)
	}
}
