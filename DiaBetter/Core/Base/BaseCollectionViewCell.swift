//
//  BaseCollectionViewCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.04.2023.
//

import UIKit
import Combine

class BaseCollectionViewCell: UICollectionViewCell {
	//MARK: - Properties
	var cancellables = Set<AnyCancellable>()
	
	//MARK: - Overriden methods
	override func prepareForReuse() {
		super.prepareForReuse()
		cancellables.removeAll()
	}
}

//MARK: - Extension UIElementsBuilder
extension BaseCollectionViewCell: UIElementsBuilder { }
