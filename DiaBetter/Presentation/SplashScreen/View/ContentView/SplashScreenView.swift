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
	private let wavesAnimationView = LottieAnimationView(name: "waves")

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
		addSubview(titleLabel, constraints: [
			titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -200)
		])

		addSubview(wavesAnimationView, constraints: [
			wavesAnimationView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			wavesAnimationView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			wavesAnimationView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 200),
			wavesAnimationView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 100)
		])

		wavesAnimationView.contentMode = .scaleAspectFill
	}

	func animate() {
		wavesAnimationView.loopMode = .loop
		wavesAnimationView.animationSpeed = 1.0
		wavesAnimationView.play()
	}
}
