//
//  1.swift
//  CombineNetworkManagerTest
//
//  Created by Владислав Баранкевич on 15.02.2023.
//

import Foundation

struct UserResponseModel: Decodable {
	enum CodingKeys: String, CodingKey {
		case lastLogin, userStatus, created, accountType
		case ownerId
		case socialAccount
		case name
		case diabetesType
		case basalInsulin
		case fastActingInsulin
		case blUserLocale
		case userToken = "user-token"
		case updated
		case objectId
		case email
		case userProfileImage
	}

	let lastLogin: 		   Int?
	let userStatus: 	   String?
	let created: 		   Int?
	let accountType: 	   String?
	let diabetesType: 	   String?
	let ownerId: 		   String?
	let socialAccount: 	   String?
	let basalInsulin: 	   String?
	let name: 			   String?
	let	blUserLocale: 	   String?
	let userToken: 		   String?
	let updated: 		   Int?
	let fastActingInsulin: String
	let objectId: 		   String?
	let email: 			   String?
	let userProfileImage:  String?
}
