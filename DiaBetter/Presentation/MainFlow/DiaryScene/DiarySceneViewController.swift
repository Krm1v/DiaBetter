//
//  DiarySceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.02.2023.
//

import UIKit

final class DiarySceneViewController: BaseViewController<DiarySceneViewModel> {
	//MARK: - Properties
	private let contentView = DiarySceneView()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavBar()
	}
}

//MARK: - Private extension
private extension DiarySceneViewController {
	func setupNavBar() {
		navigationController?.navigationBar.prefersLargeTitles = true
		title = Localization.diary
	}
}
