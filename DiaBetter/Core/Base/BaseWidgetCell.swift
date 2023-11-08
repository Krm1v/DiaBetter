//
//  BaseWidgetCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 28.05.2023.
//

import UIKit
import Combine

internal class BaseWidgetCell: BaseCollectionViewCell {
	// MARK: - UI Elements
	lazy var titleLabel = buildUserInfoLabel()
	lazy var segmentedControl = UISegmentedControl()
	lazy var hStack = buildStackView(axis: .horizontal,
									 alignment: .fill,
									 distribution: .fillProportionally,
									 spacing: .zero)
	lazy var substrateView = buildView(with: Colors.darkNavyBlue.color)

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
private extension BaseWidgetCell {
	func setupUI() {
		setupLayout()
		substrateView.rounded(Constants.basicCornerRadius)
		backgroundColor = .clear
		titleLabel.textColor = .white
		segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.backgroundColor = Colors.darkNavyBlue.color
		segmentedControl.selectedSegmentTintColor = Colors.customPink.color
	}

	func setupLayout() {
		addSubview(substrateView, constraints: [
			substrateView.leadingAnchor.constraint(equalTo: leadingAnchor),
			substrateView.trailingAnchor.constraint(equalTo: trailingAnchor),
			substrateView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		addSubview(hStack, constraints: [
			hStack.topAnchor.constraint(equalTo: topAnchor),
			hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
			hStack.trailingAnchor.constraint(equalTo: trailingAnchor),
			hStack.bottomAnchor.constraint(equalTo: substrateView.topAnchor,
										   constant: -Constants.basicInset)
		])

		segmentedControl.widthAnchor.constraint(equalToConstant: self.frame.width / 3)
			.isActive = true
		[titleLabel, segmentedControl].forEach { hStack.addArranged($0) }
	}
}

// MARK: - Constants
private enum Constants {
	static let basicCornerRadius: CGFloat = 12
	static let basicInset: 		  CGFloat = 8
}
