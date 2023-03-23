//
//  LoginSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 24.02.2023.
//

import UIKit
import Combine

final class LoginSceneViewController: BaseViewController<LoginSceneViewModel> {
	//MARK: - Properties
	private let contentView = LoginSceneView()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupBindings()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavBar()
	}
}

//MARK: - Private extension
private extension LoginSceneViewController {
	func setupNavBar() {
		navigationController?.navigationBar.isHidden = true
	}
	
	func setupBindings() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .emailChanged(let text):
					viewModel.email = text
				case .passwordChanged(let text):
					viewModel.password = text
				case .loginTapped:
					viewModel.loginUser()
				case .restorePasswordTapped:
					viewModel.moveToResetPasswordScene()
				case .createAccountTapped:
					viewModel.moveToCreateAccountScene()
				}
			}
			.store(in: &cancellables)
	}
}
