//
//  CAGradientLayer+CABaseAnimation.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.06.2023.
//

import UIKit

extension CAGradientLayer {
	func setColors(animation: CABasicAnimation,
				   _ newColors: [CGColor],
				   animated: Bool = true,
				   duration: TimeInterval = 0,
				   timingFuncName: CAMediaTimingFunctionName? = nil) {
		if !animated {
			self.colors = newColors
			return
		}
		
		animation.keyPath = "colors"
		animation.fromValue = self.colors
		animation.toValue = newColors
		animation.duration = duration
		animation.isRemovedOnCompletion = false
		animation.fillMode = .forwards
		animation.timingFunction = CAMediaTimingFunction(name: timingFuncName ?? .linear)
		add(animation, forKey: "colorsChangeAnimation")
	}
}
