//
//  UserProfilePictureDomainModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.04.2023.
//

import Foundation

struct UserProfilePictureDomainModel: Codable {
	//MARK: - Properties
	let fileURL: String
	
	//MARK: - Init
	init(fileURL: String) {
		self.fileURL = fileURL
	}
	
	init(_ response: UserProfilePictureResponse) {
		self.fileURL = response.fileURL
	}
}
