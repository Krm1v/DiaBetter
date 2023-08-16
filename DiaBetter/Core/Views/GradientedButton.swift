//
//  GradientedButton.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 24.02.2023.
//

import UIKit

final class GradientedButton: UIButton {
	//MARK: - Properties
	var lineWidth: CGFloat = Constants.lineWidth { didSet { setNeedsLayout() } }
	var cornerRadius: CGFloat = Constants.cornerRadius { didSet { setNeedsLayout() } }
	
	let borderLayer: CAGradientLayer = {
		let borderLayer = CAGradientLayer()
		borderLayer.type = .axial
		borderLayer.colors = [Constants.primaryLoginButtonColor.cgColor,
							  Colors.customPink.color.cgColor]
		borderLayer.startPoint = CGPoint(x: .zero, y: 1)
		borderLayer.endPoint = CGPoint(x: 1, y: .zero)
		return borderLayer
	}()
	
	//MARK: - Init
	override init(frame: CGRect = .zero) {
		super.init(frame: frame)
		configure()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configure()
	}
	
	//MARK: - Methods
	override func layoutSubviews() {
		super.layoutSubviews()
		borderLayer.frame = bounds
		let mask = CAShapeLayer()
		let rect = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
		mask.path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
		mask.lineWidth = lineWidth
		mask.fillColor = UIColor.clear.cgColor
		mask.strokeColor = UIColor.white.cgColor
		borderLayer.mask = mask
	}
}

//MARK: - Private extension
private extension GradientedButton {
	func configure() {
		layer.addSublayer(borderLayer)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let primaryLoginButtonColor = UIColor(red: 224/255,
												 green: 0/255,
												 blue: 0/255,
												 alpha: 1)
	static let secondaryLoginButtonGradientColor = UIColor(red: 214/255,
														   green: 0/255,
														   blue: 255/255,
														   alpha: 1)
	static let lineWidth: CGFloat = 2
	static let cornerRadius: CGFloat = 7
}
