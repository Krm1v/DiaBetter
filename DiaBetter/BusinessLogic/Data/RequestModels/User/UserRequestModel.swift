//
//  RegisterUserRequestModel.swift
//  CombineNetworkManagerTest
//
//  Created by Владислав Баранкевич on 15.02.2023.
//

import Foundation

struct UserRequestModel: Encodable {
    let basalInsulin: 	   String
    let diabetesType: 	   String
    let password: 		   String
    let email: 			   String
    let fastActingInsulin: String
    let name: 			   String
    let userProfileImage:  String?
}
