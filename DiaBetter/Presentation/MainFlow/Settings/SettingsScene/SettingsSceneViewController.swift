//
//  SettingsSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.03.2023.
//

import UIKit
import Combine

final class SettingsSceneViewController: BaseViewController<SettingsSceneViewModel> {
	//MARK: - Properties
	private let contentView = SettingsSceneView()
	
	//MARK: - UIView lifecycle
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		setupActions()
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavigationBar()
	}
}

//MARK: - Private extension
private extension SettingsSceneViewController {
	func setupActions() {
		contentView.actionPublisher
			.sink { [unowned self] actions in
				switch actions {
				case .cellTapped(let setting):
					viewModel.openUserSettings(setting)
				}
			}
			.store(in: &cancellables)
	}
	
	func setupNavigationBar() {
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always
		title = Localization.settings
	}
}
