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
		titleLabel.font = FontFamily.Montserrat.regular.font(size: 13)
		titleLabel.numberOfLines = 0
	}

	func addSubs() {
        addSubview(titleLabel, constraints: [
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                 constant: -16)
        ])
	}
}

// MARK: - Extension UIElementsBuilder
extension AppleHealthSectionFooter: UIElementsBuilder { }
