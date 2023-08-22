//
//  BackupPlainCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.07.2023.
//

import UIKit

final class BackupPlainCell: BaseCollectionViewCell {
	// MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel(fontSize: 15)

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
	func configure(_ model: BackupShareCellModel) {
		titleLabel.text = model.title
		titleLabel.textColor = model.color.color
	}
}

// MARK: - Private extension
private extension BackupPlainCell {
	func setupUI() {
		self.backgroundColor = .black
		rounded(12)
		titleLabel.font = FontFamily.Montserrat.regular.font(size: 15)
		setupLayout()
	}

	func setupLayout() {
		addSubview(
			titleLabel,
			constraints: [
				titleLabel.leadingAnchor.constraint(
					equalTo: self.leadingAnchor,
					constant: 16),

				titleLabel.centerYAnchor.constraint(
					equalTo: self.centerYAnchor)])
	}
}
