//
//  User.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 22.02.2023.
//

import Foundation

struct User: Codable {
	//MARK: - Properties
	var name: String?
	var email: String?
	var password: String?
	var remoteId: String?
	var diabetesType: String?
	var basalInsulin: String?
	var fastActingInsulin: String?
	var userProfileImage: String?
	var updated: Int?
	
	//MARK: - Init
	init(name: String? = nil,
		 email: String? = nil,
		 password: String? = nil,
		 remoteId: String? = nil,
		 diabetesType: String? = nil,
		 basalInsulin: String? = nil,
		 fastActingInsulin: String? = nil,
		 userProfileImage: String? = nil) {
		self.name = name
		self.email = email
		self.password = password
		self.remoteId = remoteId
		self.diabetesType = diabetesType
		self.basalInsulin = basalInsulin
		self.fastActingInsulin = fastActingInsulin
		self.userProfileImage = userProfileImage
	}
	
	init(_ response: UserResponseModel) {
		self.name = response.name
		self.email = response.email
		self.remoteId = response.objectId
		self.diabetesType = response.diabetesType
		self.fastActingInsulin = response.fastActingInsulin
		self.basalInsulin = response.basalInsulin
		self.userProfileImage = response.userProfileImage
		self.updated = response.updated
	}
}
