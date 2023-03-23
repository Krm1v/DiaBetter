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
		tabBarAppearance.backgroundColor = .white
		tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 214/255,
																										   green: 0/255,
																										   blue: 255/255,
																										   alpha: 1)]
		tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
		tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.black
		tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 214/255,
																			  green: 0/255,
																			  blue: 255/255,
																			  alpha: 1)
		tabBar.standardAppearance = tabBarAppearance
		if #available(iOS 15.0, *) {
			tabBar.scrollEdgeAppearance = tabBarAppearance
		}
	}
}
