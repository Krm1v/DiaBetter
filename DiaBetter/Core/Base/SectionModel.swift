//
//  SectionModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.03.2023.
//

import Foundation

struct SectionModel<Section: Hashable, Item: Hashable> {
	let section: Section
	var items: [Item]
}
