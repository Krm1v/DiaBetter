//
//  CustomActivityIndicator.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 02.06.2023.
//

import UIKit

final class CustomActivityIndicator: UIView {
	//MARK: - Properties
	static let tagValue = Constants.tagValue
	private let spinningCircle = CAShapeLayer()
	private let viewContainer = UIView()
	
	var isLoading: Bool = false {
		didSet {
			isLoading ? animate() : stopAnimation()
		}
	}
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configure()
	}
}

//MARK: - Private extension
private extension CustomActivityIndicator {
	func configure() {
		tag = Constants.tagValue
		addSubview(viewContainer)
		viewContainer.frame.size = CGSize(width: Constants.frameWidth, height: Constants.frameHeight)
		viewContainer.center = self.center
		let rect = viewContainer.bounds
		let path = UIBezierPath(ovalIn: rect)
		spinningCircle.path = path.cgPath
		spinningCircle.strokeColor = Colors.customPink.color.cgColor
		spinningCircle.fillColor = UIColor.clear.cgColor
		spinningCircle.lineWidth = Constants.lineWidth
		spinningCircle.strokeEnd = Constants.strokeEnd
		spinningCircle.lineCap = .round
		viewContainer.layer.addSublayer(spinningCircle)
		viewContainer.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func animate() {
		UIView.animate(withDuration: Constants.animationDuration,
					   delay: .zero,
					   options: .curveLinear) { [weak self] in
			guard let self = self else { return }
			self.viewContainer.transform = CGAffineTransform(rotationAngle: .pi)
		} completion: { [weak self] _ in
			guard let self = self else { return }
			UIView.animate(withDuration: Constants.animationDuration,
						   delay: .zero,
						   options: .curveLinear) {
				self.viewContainer.transform = CGAffineTransform(rotationAngle: .zero)
			} completion: { _ in self.animate() }
		}
	}
	
	func stopAnimation() {
		UIView.performWithoutAnimation {
			viewContainer.layer.removeAllAnimations()
		}
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let frameWidth: 		  CGFloat = 50
	static let frameHeight: 	  CGFloat = 50
	static let lineWidth:		  CGFloat = 10
	static let strokeEnd: 		  CGFloat = 0.35
	static let animationDuration: TimeInterval = 0.6
	static let tagValue: Int = 	  1234123
}
