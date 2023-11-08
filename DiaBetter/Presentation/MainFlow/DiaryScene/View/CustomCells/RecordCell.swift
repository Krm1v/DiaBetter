//
//  RecordCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.04.2023.
//

import UIKit
import Combine

final class RecordCell: BaseCollectionViewCell {
	// MARK: - UI Elements
	private lazy var hStack = buildStackView(axis: .horizontal,
											 alignment: .fill,
											 distribution: .fillEqually,
											 spacing: Constants.defaultStackViewSpacing)
	private lazy var timeLabel = buildUserInfoLabel()
	private lazy var glucoseBox = BoxElementView()
	private lazy var mealBox = BoxElementView()
	private lazy var fastInsulinBox = BoxElementView()
	private lazy var longInsulinBox = BoxElementView()

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}

	// MARK: - Public methods
	func configure(with model: DiaryRecordCellModel) {
		timeLabel.text = model.time
		glucoseBox.setInfo(model.glucoseInfo)
		mealBox.setInfo(model.mealInfo)
		fastInsulinBox.setInfo(model.fastInsulinInfo)
		longInsulinBox.setInfo(model.longInsulinInfo)
	}
}

// MARK: - Private extension
private extension RecordCell {
	func setupUI() {
		self.backgroundColor = .black
		timeLabel.textColor = .systemGray
		timeLabel.textAlignment = .center
		setupLayout()
	}

	func setupLayout() {
		addSubview(hStack, withEdgeInsets: .all(Constants.defaultEdgeInsets))
		[
			timeLabel,
			glucoseBox,
			mealBox,
			fastInsulinBox,
			longInsulinBox
		]
			.forEach { hStack.addArrangedSubview($0) }
	}
}

// MARK: - Constants
private enum Constants {
	static let defaultStackViewSpacing: CGFloat = 8
	static let defaultEdgeInsets: 	    CGFloat = 8
}
