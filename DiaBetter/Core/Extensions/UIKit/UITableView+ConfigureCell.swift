//
//  UITableView+ConfigureCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import UIKit

extension UITableView {
	func configureCell<T: SelfConfiguringCell>(cellType: T.Type,
											   indexPath: IndexPath) -> T {
		guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseID,
											 for: indexPath) as? T else {
			fatalError("Error \(cellType)")
		}
		return cell
	}
}
