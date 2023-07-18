//
//  DataSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.07.2023.
//

import UIKit
import Combine

final class DataSceneViewConroller: BaseViewController<DataSceneViewModel> {
	//MARK: - Properties
	private let contentView = DataSceneView()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	//MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		title = Localization.data
	}
}
