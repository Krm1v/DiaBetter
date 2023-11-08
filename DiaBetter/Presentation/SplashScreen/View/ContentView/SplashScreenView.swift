//
//  SplashScreenView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 29.08.2023.
//

import UIKit
import Lottie

final class SplashScreenView: BaseView {
    // MARK: - UI Elements
    private lazy var titleLabel = buildTitleLabel()
    private let wavesAnimationView = LottieAnimationView(name: Constants.animationName)
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        animate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        animate()
    }
}

// MARK: - Private extension
private extension SplashScreenView {
    func setupUI() {
        backgroundColor = .black
        addSubview(
            titleLabel,
            constraints: [
                titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                
                titleLabel.centerYAnchor.constraint(
                    equalTo: self.centerYAnchor,
                    constant: -Constants.largeInset)
            ])
        
        addSubview(
            wavesAnimationView,
            constraints: [
                wavesAnimationView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                wavesAnimationView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                
                wavesAnimationView.bottomAnchor.constraint(
                    equalTo: self.bottomAnchor,
                    constant: Constants.largeInset),
                
                wavesAnimationView.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: Constants.defaultInset)
            ])
        
        wavesAnimationView.contentMode = .scaleAspectFill
    }
    
    func animate() {
        wavesAnimationView.loopMode = .loop
        wavesAnimationView.animationSpeed = Constants.animationSpeed
        wavesAnimationView.play()
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let animationName: String = "waves"
    static let animationSpeed: CGFloat = 1.0
    static let largeInset: CGFloat = 200
    static let defaultInset: CGFloat = 100
}
