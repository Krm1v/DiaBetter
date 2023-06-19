//
//  BaseTableViewCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import UIKit
import Combine

class BaseTableViewCell: UITableViewCell {
	//MARK: - Properties
	var cancellables = Set<AnyCancellable>()
	
	//MARK: - Overriden methods
	override func prepareForReuse() {
		super.prepareForReuse()
		cancellables.removeAll()
	}
}
