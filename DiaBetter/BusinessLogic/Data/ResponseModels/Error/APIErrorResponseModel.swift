//
//  APIErrorResponseModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 11.08.2023.
//

import Foundation

struct APIErrorResponseModel: Decodable {
    let code: 	 Int
    let message: String
}
