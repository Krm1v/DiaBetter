//
//  AppleHealthSectionFooter.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.07.2023.
//

import UIKit

final class AppleHealthSectionFooter: UICollectionReusableView {
    // MARK: - UI Elements
    lazy var titleLabel = buildUserInfoLabel()
    
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
private extension AppleHealthSectionFooter {
    func setupUI() {
        addSubs()
        titleLabel.textColor = .systemGray
        titleLabel.font = FontFamily.Montserrat.regular.font(
            size: Constants.defaultFontSize)
        titleLabel.numberOfLines = Constants.numberOfLines
    }
    
    func addSubs() {
        addSubview(
            titleLabel,
            constraints: [
                titleLabel.leadingAnchor.constraint(
                    equalTo: self.leadingAnchor,
                    constant: Constants.defaultEdgeInset),
                
                titleLabel.trailingAnchor.constraint(
                    equalTo: self.trailingAnchor,
                    constant: -Constants.defaultEdgeInset)
            ])
    }
}

// MARK: - Extension UIElementsBuilder
extension AppleHealthSectionFooter: UIElementsBuilder { }

// MARK: - Constants
fileprivate enum Constants {
    static let defaultEdgeInset: CGFloat = 16
    static let defaultFontSize: CGFloat = 13
    static let numberOfLines: Int = 0
}
