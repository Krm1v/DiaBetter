//
//  HeaderCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.06.2023.
//

import UIKit
import Combine

final class AppInfoCell: BaseCollectionViewCell {
	// MARK: - UI Elements
	private lazy var appIconImageView = UIImageView()
	private lazy var appVersionLabel = buildUserInfoLabel()
	private lazy var buildVersionLabel = buildUserInfoLabel()
	private lazy var companyDescriptionLabel = buildUserInfoLabel()

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
	func configure(_ model: AppInfoCellModel) {
		appIconImageView.image = UIImage(data: model.appIcon)
		appVersionLabel.text = model.appVersion
		buildVersionLabel.text = model.buildVersion
		companyDescriptionLabel.text = model.companyInfo
	}
}

// MARK: - Private extension
private extension AppInfoCell {
	func setupUI() {
		self.rounded(12)
		buildVersionLabel.font = FontFamily.Montserrat.regular.font(size: 13)
		appIconImageView.rounded(12)
		appIconImageView.layer.borderColor = UIColor.white.cgColor
		appIconImageView.layer.borderWidth = 1
		setupLayout()
	}

	func setupLayout() {
		addSubview(
			appIconImageView,
			constraints: [
				appIconImageView.heightAnchor.constraint(
					equalToConstant: 85),

				appIconImageView.widthAnchor.constraint(
					equalToConstant: 85),

				appIconImageView.topAnchor.constraint(
					equalTo: self.topAnchor,
					constant: 16),

				appIconImageView.centerXAnchor.constraint(
					equalTo: centerXAnchor)])

		addSubview(
			appVersionLabel,
			constraints: [
				appVersionLabel.topAnchor.constraint(
					equalTo: appIconImageView.bottomAnchor,
					constant: 8),

				appVersionLabel.centerXAnchor.constraint(
					equalTo: centerXAnchor)])

		addSubview(
			buildVersionLabel,
			constraints: [
				buildVersionLabel.topAnchor.constraint(
					equalTo: appVersionLabel.bottomAnchor,
					constant: 8),

				buildVersionLabel.centerXAnchor.constraint(
					equalTo: self.centerXAnchor)])

		addSubview(
			companyDescriptionLabel,
			constraints: [
				companyDescriptionLabel.topAnchor.constraint(
					equalTo: buildVersionLabel.bottomAnchor,
					constant: 8),

				companyDescriptionLabel.centerXAnchor.constraint(
					equalTo: centerXAnchor)])
	}
}
