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
	
	//MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		title = Localization.settings
	}
}

//MARK: - Private extension
private extension SettingsSceneViewController {
	func setupActions() {
		contentView.actionPublisher
			.sink { [unowned self] actions in
				switch actions {
				case .cellTapped(let setting):
					switch setting {
					case .user:
						viewModel.openDetailSettingsScreen(.user)
					case .notifications:
						viewModel.openDetailSettingsScreen(.notifications)
					default: break
					}
				}
			}
			.store(in: &cancellables)
	}
}
