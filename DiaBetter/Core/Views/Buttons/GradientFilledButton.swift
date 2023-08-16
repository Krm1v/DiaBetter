//
//  GradientFilledButton.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.06.2023.
//

import UIKit

final class GradientFilledButton: UIButton {
	// MARK: - Properties
	var primaryColor = UIColor.red
	var secondaryColor = Colors.customPink.color

	lazy var gradientLayer: CAGradientLayer = {
		let gradient = CAGradientLayer()
		gradient.type = .axial
		gradient.colors = [primaryColor.cgColor,
						   secondaryColor.cgColor]
		gradient.startPoint = CGPoint(x: 0, y: 0)
		gradient.endPoint = CGPoint(x: 1, y: 1)
		layer.insertSublayer(gradient, at: 0)
		return gradient
	}()

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configure()
	}

	// MARK: - Methods
	override func layoutSubviews() {
		super.layoutSubviews()
		gradientLayer.frame = bounds
		self.rounded(Constants.cornerRadius)
	}
}

// MARK: - Private extension
private extension GradientFilledButton {
	func configure() {
		layer.addSublayer(gradientLayer)
	}
}

// MARK: - Constants
private enum Constants {
	static let cornerRadius: CGFloat = 7
}
