//
//  CreateUserProfileViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.02.2023.
//

import UIKit
import Combine

final class CreateUserProfileViewController: BaseViewController<CreateUserProfileViewModel> {
	// MARK: - Properties
	private let contentView = CreateUserProfileView()

	// MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupActions()
	}

	// MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		navigationItem.hidesBackButton = true
		title = Localization.createAccount
	}
}

// MARK: - Private extension
private extension CreateUserProfileViewController {
	func setupActions() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .emailTextFieldChanged(let text):
					viewModel.email = text
				case .passwordTextFieldChanged(let text):
					viewModel.password = text
				case .backToLoginTapped:
					viewModel.backToLogin()
				case .createAccountTapped:
					viewModel.createAccount()
				}
			}
			.store(in: &cancellables)
	}
}
