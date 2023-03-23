//
//  CreateUserProfileViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.02.2023.
//

import UIKit
import Combine

final class CreateUserProfileViewController: BaseViewController<CreateUserProfileViewModel> {
	//MARK: - Properties
	private let contentView = CreateUserProfileView()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupActions()
		setupNavBar()
	}
}

//MARK: - Private extension
private extension CreateUserProfileViewController {
	func setupNavBar() {
		title = Constants.navTitleText
		navigationController?.navigationBar.isHidden = false
		navigationController?.navigationBar.prefersLargeTitles = false
		navigationItem.hidesBackButton = true
		navigationController?.interactivePopGestureRecognizer?.delegate = nil
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
	}
	
	func setupActions() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .emailTextFieldChanged(let text):
					viewModel.email = text
				case .passwordTextFieldChanged(let text):
					viewModel.password = text
				case .nameTextFieldChanged(let text):
					viewModel.name = text
				case .countryTextFieldChanged(let text):
					viewModel.country = text
				case .diabetesTypeTextFieldChanged(let text):
					viewModel.diabetesType = text
				case .fastActingInsulinTextFieldChanged(let text):
					viewModel.fastInsulin = text
				case .basalInsulinTextFieldChanged(let text):
					viewModel.longInsulin = text
				case .backToLoginTapped:
					viewModel.backToLogin()
				case .createAccountTapped:
					viewModel.createUser()
				}
			}
			.store(in: &cancellables)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let navTitleText = Localization.createAccount
}
