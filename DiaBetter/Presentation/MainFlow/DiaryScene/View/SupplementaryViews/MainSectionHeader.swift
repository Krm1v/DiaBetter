//
//  MainSectionHeader.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 27.04.2023.
//

import UIKit

final class MainSectionHeader: UICollectionReusableView {
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
private extension MainSectionHeader {
	func setupUI() {
		addSubs()
		titleLabel.textColor = .white
	}
	
	func addSubs() {
		addSubview(titleLabel, withEdgeInsets: .init(top: .zero,
													 left: 16,
													 bottom: .zero,
													 right: .zero))
	}
}
