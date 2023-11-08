//
//  UICollectionViewCell+ReuseID.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 29.05.2023.
//

import UIKit

extension UICollectionViewCell: SelfConfiguringCell {
	static var reuseID: String {
		Self.description()
	}
}
