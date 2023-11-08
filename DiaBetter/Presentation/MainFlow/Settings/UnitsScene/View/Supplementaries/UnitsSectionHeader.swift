//
//  UnitsSectionHeader.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.06.2023.
//

import UIKit

final class UnitsSectionHeader: UICollectionReusableView {
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
private extension UnitsSectionHeader {
    func setupUI() {
        addSubs()
        titleLabel.textColor = .systemGray
        titleLabel.font = FontFamily.Montserrat.regular.font(
            size: Constants.defaultFontSize)
    }
    
    func addSubs() {
        addSubview(
            titleLabel,
            withEdgeInsets: .init(
                top: .zero,
                left: Constants.defaultEdgeInset,
                bottom: .zero,
                right: .zero))
    }
}

// MARK: - Extension UIElementsBuilder
extension UnitsSectionHeader: UIElementsBuilder { }

// MARK: - Constants
fileprivate enum Constants {
    static let defaultFontSize: CGFloat = 15
    static let defaultEdgeInset: CGFloat = 16
}
