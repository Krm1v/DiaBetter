//
//  BaseFooterSupplementaryView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.07.2023.
//

import UIKit

class BaseFooterSupplementaryView: UICollectionReusableView {
	//MARK: - UI Elements
	private lazy var titleLabel = buildUserInfoLabel()
	
	//MARK: - Properties
	var titleText: String? {
		get { return titleLabel.text }
		set { titleLabel.text = newValue }
	}
	
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
private extension BaseFooterSupplementaryView {
	func setupUI() {
		addSubs()
		titleLabel.text = titleText
		titleLabel.textColor = .systemGray
		titleLabel.font = FontFamily.Montserrat.regular.font(size: 15)
		titleLabel.numberOfLines = .zero
	}
	
	func addSubs() {
		addSubview(titleLabel, withEdgeInsets: .init(top: .zero,
													 left: 16,
													 bottom: .zero,
													 right: 16))
	}
}

//MARK: - Extension UIElementsBuilder
extension BaseFooterSupplementaryView: UIElementsBuilder { }

