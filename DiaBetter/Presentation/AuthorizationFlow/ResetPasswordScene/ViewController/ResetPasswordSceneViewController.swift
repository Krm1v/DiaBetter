//
//  ResetPasswordSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 02.03.2023.
//

import UIKit
import Combine

final class ResetPasswordSceneViewController: BaseViewController<ResetPasswordSceneViewModel> {
    // MARK: - Properties
    private let contentView = ResetPasswordSceneView()
    
    // MARK: - UIView lifecycle methods
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    // MARK: - Overriden methods
    override func setupNavBar() {
        super.setupNavBar()
        title = Localization.restorePassword
        navigationItem.hidesBackButton = true
    }
}

// MARK: - Private extension
private extension ResetPasswordSceneViewController {
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
