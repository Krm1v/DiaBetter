//
//  ResetPasswordSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 02.03.2023.
//

import UIKit
import Combine

final class ResetPasswordSceneViewController: BaseViewController<ResetPasswordSceneViewModel> {
	//MARK: - Properties
	private let contentView = ResetPasswordSceneView()
	
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
private extension ResetPasswordSceneViewController {
	func setupNavBar() {
		navigationController?.navigationBar.isHidden = false
		title = "Reset password"
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.hidesBackButton = true
		navigationController?.interactivePopGestureRecognizer?.delegate = nil
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
	}
	
	func setupBindings() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .emailTextFieldChanged(let text):
					viewModel.email = text
				case .resetPasswordButtonTapped:
					viewModel.resetPassword()
				case .backToLoginSceneButtonTapped:
					viewModel.moveBackToLoginScene()
				}
			}
			.store(in: &cancellables)
	}
}
