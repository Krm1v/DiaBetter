//
//  Bundle+AppVersion.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.06.2023.
//

import Foundation

extension Bundle {
	var releaseVersionNumber: String? {
		return infoDictionary?["CFBundleShortVersionString"] as? String
	}
	var buildVersionNumber: String? {
		return infoDictionary?["CFBundleVersion"] as? String
	}
}
