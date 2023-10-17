//
//  UICollectionView+ConfigureCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.04.2023.
//

import UIKit

extension UICollectionView {
	func configureCell<T: SelfConfiguringCell>(
		cellType: T.Type,
		indexPath: IndexPath
	) -> T {
		guard let cell = dequeueReusableCell(
			withReuseIdentifier: cellType.reuseID,
			for: indexPath) as? T else {
			fatalError("Cell config error")
		}
		return cell
	}
}
