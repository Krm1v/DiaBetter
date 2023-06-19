//
//  UITableViewCell+SelfConfiguringCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import UIKit

extension UITableViewCell: SelfConfiguringCell {
	static var reuseID: String {
		Self.description()
	}
}

