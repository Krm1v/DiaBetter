//
//  BackupCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.07.2023.
//

import UIKit
import Combine

final class BackupCell: BaseCollectionViewCell {
	// MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel(fontSize: 15)
	private lazy var chevronImage = UIImageView()

	// MARK: - Properties

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
	func configure(_ model: BackupCellModel) {
		titleLabel.text = model.title
	}
}

// MARK: - Private extension
private extension BackupCell {
	func setupUI() {
		self.backgroundColor = .black
		rounded(12)
		titleLabel.font = FontFamily.Montserrat.regular.font(size: 15)
		chevronImage.image = UIImage(
			systemName: "chevron.right")?.withTintColor(
				.white,
				renderingMode: .alwaysOriginal)

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

		addSubview(
			chevronImage,
			constraints: [
				chevronImage.centerYAnchor.constraint(
					equalTo: self.centerYAnchor),

				chevronImage.trailingAnchor.constraint(
					equalTo: self.trailingAnchor,
					constant: -16)])
	}
}
