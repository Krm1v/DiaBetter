//
//  CollectionViewProtocols.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.03.2023.
//

import Foundation

protocol SelfConfiguringCell: AnyObject {
	static var reuseID: String { get }
}

