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
    
    private lazy var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: Keys.bounceAnimationKeyPath)
        bounceAnimation.values = Constants.bounceAnimationValues
        bounceAnimation.duration = Constants.bounceAnimationDuration
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()
    
    // MARK: - Init
    init(
        viewModel: MainTabBarViewModel,
        viewControllers: [UIViewController]
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overriden methods
    override func tabBar(
        _ tabBar: UITabBar,
        didSelect item: UITabBarItem
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.impactFeedbackGenerator.prepare()
            self.impactFeedbackGenerator.impactOccurred()
            
            guard
                let idx = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > idx + 1,
                let imageView = tabBar.subviews[idx + 1].subviews.dropFirst().compactMap({ $0 as? UIImageView }).first
            else {
                return
            }
            imageView.layer.add(self.bounceAnimation, forKey: nil)
        }
    }
    
    // MARK: - UIView lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setValue(
            MainTabBar(frame: tabBar.frame),
            forKey: Keys.tabBar)
        
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

// MARK: - Constants
fileprivate enum Constants {
    static let bounceAnimationValues = [1.0, 1.4, 0.9, 1.02, 1.0]
    static let bounceAnimationDuration: CFTimeInterval = TimeInterval(0.3)
}

// MARK: - Keys
fileprivate enum Keys {
    static let bounceAnimationKeyPath = "transform.scale"
    static let tabBar = "tabBar"
}
