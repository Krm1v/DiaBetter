//
//  SplashScreenViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 29.08.2023.
//

import UIKit

final class SplashScreenViewController: BaseViewController<SplashScreenViewModel> {
    // MARK: - Properties
    private let contentView = SplashScreenView()
    
    // MARK: - UIView lifecycle methods
    override func loadView() {
        self.view = contentView
    }
}
