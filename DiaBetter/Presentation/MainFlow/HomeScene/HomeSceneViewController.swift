//
//  HomeSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import UIKit

final class HomeSceneViewController: BaseViewController<HomeSceneViewModel> {
	//MARK: - Properties
	private let contentView = HomeSceneView()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		setupBindings()
		super.viewDidLoad()
		setupNavBar()
	}
}

//MARK: - Private extension
private extension HomeSceneViewController {
	func setupNavBar() {
		contentView.setupSettingsButton(for: self)
		title = Localization.home
		navigationController?.navigationBar.prefersLargeTitles = true
		
	}
	
	func setupBindings() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .settingsButtonTapped:
					viewModel.openSettings()
				}
			}
			.store(in: &cancellables)
	}
}
