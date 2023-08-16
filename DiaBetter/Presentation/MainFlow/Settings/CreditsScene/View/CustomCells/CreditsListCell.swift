//
//  ListCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.06.2023.
//

import UIKit
import Combine

final class CreditsListCell: BaseCollectionViewCell {
	// MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel()
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
	func configure(_ model: CreditsListCellModel) {
		titleLabel.text = model.title
	}
}

// MARK: - Private extension
private extension CreditsListCell {
	func setupUI() {
		backgroundColor = Colors.darkNavyBlue.color
		rounded(12)
		setupLayout()
		titleLabel.font = FontFamily.Montserrat.regular.font(size: 15)
		chevronImage.image = UIImage(
			systemName: "chevron.right")?
			.withTintColor(.white, renderingMode: .alwaysOriginal)
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
