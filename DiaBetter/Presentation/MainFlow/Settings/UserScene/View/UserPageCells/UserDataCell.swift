//
//  UserDataCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.03.2023.
//

import UIKit

final class UserDataCell: UICollectionViewCell {
	//MARK: - UI Elements
	private lazy var iconImage: UIImageView = {
		let icon = UIImageView()
		icon.translatesAutoresizingMaskIntoConstraints = false
		icon.backgroundColor = .red
		icon.contentMode = .scaleAspectFill
		icon.rounded(Constants.basicCornerRadius)
		return icon
	}()
	
	private lazy var titleLabel = buildFieldTitleLabel()
	private(set) lazy var userTextField: UITextField = {
		let textField = UITextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.borderStyle = .none
		textField.font = FontFamily.Montserrat.regular.font(size: 17)
		return textField
	}()
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
	
	//MARK: - Public methods
	func configure(with model: UserDataSettingsModel) {
		titleLabel.text = model.title
		userTextField.text = model.textFieldValue
	}
}

//MARK: - Private extension
private extension UserDataCell {
	func setupUI() {
		backgroundColor = .systemGray5
		addSubs()
		setupConstraints()
	}
	
	func addSubs() {
//		addSubview(iconImage)
		addSubview(titleLabel)
		addSubview(userTextField)
	}
	
	func setupConstraints() {
//		iconImage.leadingAnchor.constraint(equalTo: leadingAnchor,
//										   constant: Constants.basicLargeEdgeInset)
//		.isActive = true
//		iconImage.centerYAnchor.constraint(equalTo: centerYAnchor)
//			.isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
			.isActive = true
		titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
											constant: Constants.basicSmallEdgeInset)
		.isActive = true
		userTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.basicSmallEdgeInset)
			.isActive = true
		userTextField.centerYAnchor.constraint(equalTo: centerYAnchor)
			.isActive = true
	}
}

//MARK: - Extension SelfConfiguringTableViewCell
extension UserDataCell: UIElementsBuilder {}
extension UserDataCell: SelfConfiguringCollectionViewCell {
	static var reuseID: String {
		return "userDataCell"
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let basicLargeEdgeInset: CGFloat = 16
	static let basicSmallEdgeInset: CGFloat = 8
	static let basicCornerRadius: CGFloat = 20
}

