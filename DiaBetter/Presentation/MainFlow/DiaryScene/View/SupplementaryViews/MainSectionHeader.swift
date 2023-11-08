//
//  MainSectionHeader.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 27.04.2023.
//

import UIKit

final class MainSectionHeader: UICollectionReusableView {
    // MARK: - UI Elements
    lazy var titleLabel = buildUserInfoLabel()
    lazy private var bluredView = UIVisualEffectView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Private extension
private extension MainSectionHeader {
    func setupUI() {
        addSubs()
        titleLabel.textColor = .white
        self.backgroundColor = .clear
        bluredView.effect = UIBlurEffect(style: .dark)
    }
    
    func addSubs() {
        addSubview(bluredView, withEdgeInsets: .all(.zero))
        addSubview(titleLabel, withEdgeInsets: .init(
            top: .zero,
            left: Constants.defaultInset,
            bottom: .zero,
            right: .zero))
    }
}

// MARK: - Extension UIElementsBuilder
extension MainSectionHeader: UIElementsBuilder { }

// MARK: - Constants
fileprivate enum Constants {
    static let defaultInset: CGFloat = 16
}
