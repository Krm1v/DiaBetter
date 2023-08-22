//
//  MainTabBarViewController.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import UIKit

final class MainTabBarViewController: UITabBarController {
	// MARK: - Properties
	private var viewModel: MainTabBarViewModel
	private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

	private var bounceAnimation: CAKeyframeAnimation = {
		let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
		bounceAnimation.values = [1.0, 1.4, 0.9, 1.02, 1.0]
		bounceAnimation.duration = TimeInterval(0.3)
		bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
		return bounceAnimation
	}()

	// MARK: - Init
	init(viewModel: MainTabBarViewModel, viewControllers: [UIViewController]) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		self.viewControllers = viewControllers
	}

	@available(*, unavailable) required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overriden methods
	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		impactFeedbackGenerator.prepare()
		impactFeedbackGenerator.impactOccurred()

		guard
			let idx = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > idx + 1,
			let imageView = tabBar.subviews[idx + 1].subviews.dropFirst().compactMap({ $0 as? UIImageView }).first
		else {
			return
		}
		imageView.layer.add(bounceAnimation, forKey: nil)
	}

	// MARK: - UIView lifecycle methods
	override func viewDidLoad() {
		super.viewDidLoad()
		setValue(MainTabBar(frame: tabBar.frame), forKey: "tabBar")
		viewControllers?.enumerated().reversed().forEach({ [unowned self] (ind, _) in
			selectedIndex = ind
		})
		tabBar.backgroundImage = UIImage()
		tabBar.shadowImage = UIImage()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.isHidden = true
	}
}
