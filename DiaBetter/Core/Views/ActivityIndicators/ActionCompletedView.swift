//
//  ActionCompletedView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 28.08.2023.
//

import UIKit
import Lottie

final class ActionCompletedView: UIView {
    // MARK: - Properties
    static let tagValue = Constants.tagValue
    private let lottieView = LottieAnimationView(name: Constants.animationName)
    
    var isLoading: Bool = false {
        didSet {
            isLoading ? animate() : stopAnimation()
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
}

// MARK: - Private extension
private extension ActionCompletedView {
    func configure() {
        tag = Constants.tagValue
        lottieView.contentMode = .scaleAspectFit
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lottieView)
        lottieView.centerXAnchor.constraint(equalTo: centerXAnchor)
            .isActive = true
        lottieView.centerYAnchor.constraint(equalTo: centerYAnchor)
            .isActive = true
        lottieView.heightAnchor.constraint(equalToConstant: Constants.defaultHeightWidthValue)
            .isActive = true
        lottieView.widthAnchor.constraint(equalToConstant: Constants.defaultHeightWidthValue)
            .isActive = true
    }
    
    func animate() {
        lottieView.loopMode = .playOnce
        lottieView.animationSpeed = 1
        lottieView.play()
        let notificationFeedBackGenerator = UINotificationFeedbackGenerator()
        notificationFeedBackGenerator.prepare()
        notificationFeedBackGenerator.notificationOccurred(.success)
    }
    
    func stopAnimation() {
        lottieView.stop()
    }
}

// MARK: - Constants
private enum Constants {
    static let frameWidth: 		  CGFloat = 50
    static let frameHeight: 	  CGFloat = 50
    static let lineWidth: 		  CGFloat = 10
    static let strokeEnd: 		  CGFloat = 0.35
    static let defaultHeightWidthValue: CGFloat = 100
    static let animationDuration: TimeInterval = 0.6
    static let tagValue: Int = 	  12341231
    static let animationName: String = "actionDone"
}
