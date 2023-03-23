//
//  CollectionViewProtocols.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.03.2023.
//

import Foundation

protocol SelfConfiguringCollectionViewCell: AnyObject {
	static var reuseID: String { get }
}
