//
//  AppleHealthSectionFooter.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.07.2023.
//

import UIKit

final class UnitsSectionHeader: UICollectionReusableView {
	//MARK: - UI Elements
	lazy var titleLabel = buildUserInfoLabel()
	
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
private extension UnitsSectionHeader {
	func setupUI() {
		addSubs()
		titleLabel.textColor = .systemGray
		titleLabel.font = FontFamily.Montserrat.regular.font(size: 15)
	}
	
	func addSubs() {
		addSubview(titleLabel, withEdgeInsets: .init(top: .zero,
													 left: 16,
													 bottom: .zero,
													 right: .zero))
	}
}

//MARK: - Extension UIElementsBuilder
extension UnitsSectionHeader: UIElementsBuilder { }
