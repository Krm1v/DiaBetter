//
//  UserUpdateRequestModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.03.2023.
//

import Foundation

struct UserUpdateRequestModel: Encodable {
	let basalInsulin: 	   String?
	let diabetesType: 	   String?
	let fastActingInsulin: String?
	let name: 			   String?
	let userProfileImage:  String?
}
