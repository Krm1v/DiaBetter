//
//  MainTabBarViewController.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import UIKit

final class MainTabBarViewController: UITabBarController {
	
	private var viewModel: MainTabBarViewModel
	
	init(viewModel: MainTabBarViewModel, viewControllers: [UIViewController]) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		self.viewControllers = viewControllers
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		viewControllers?.enumerated().reversed().forEach({ [unowned self] (ind, _) in
			selectedIndex = ind
		})
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.isHidden = true
		setupTabBarAppearance()
	}
}

private extension MainTabBarViewController {
	func setupTabBarAppearance() {
		let tabBarAppearance = UITabBarAppearance()
		tabBarAppearance.backgroundColor = .black
		tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: Colors.customPink.color]
		tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: Colors.customDarkenPink.color]
		tabBarAppearance.stackedLayoutAppearance.normal.iconColor = Colors.customDarkenPink.color
		tabBarAppearance.stackedLayoutAppearance.selected.iconColor = Colors.customPink.color
		tabBar.standardAppearance = tabBarAppearance
		if #available(iOS 15.0, *) {
			tabBar.scrollEdgeAppearance = tabBarAppearance
		}
	}
}
