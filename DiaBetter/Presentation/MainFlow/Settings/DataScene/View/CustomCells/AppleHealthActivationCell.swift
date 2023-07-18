//
//  AppleHealthActivationCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.07.2023.
//

import UIKit
import Combine

final class AppleHealthActivationCell: BaseCollectionViewCell {
	//MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel(fontSize: 15)
	private lazy var healthSwitch = UISwitch()
	
	//MARK: - Properties
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
}

//MARK: - Private extension
private extension AppleHealthActivationCell {
	func setupUI() {
		setupLayout()
	}
	
	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
												constant: 8),
			titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
		])
		
		addSubview(healthSwitch, constraints: [
			healthSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor,
												   constant: -8),
			healthSwitch.centerYAnchor.constraint(equalTo: self.centerYAnchor)
		])
	}
}
