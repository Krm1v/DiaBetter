//
//  UICollectionReusableView+ReuseID.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 29.05.2023.
//

import UIKit

extension UICollectionReusableView: SupplementariesConfigurationProtocol {
	static var reuseId: String {
		Self.description()
	}
}
