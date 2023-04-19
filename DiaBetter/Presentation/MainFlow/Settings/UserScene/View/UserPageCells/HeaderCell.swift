//
//  HeaderCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.03.2023.
//

import UIKit
import Combine

final class HeaderCell: UICollectionViewCell {
	//MARK: - UIElements
	private lazy var userImage: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.layer.masksToBounds = false
		image.clipsToBounds = true
		image.image = Assets.userImagePlaceholder.image
		image.contentMode = .scaleToFill
		return image
	}()
	
	private(set) lazy var editButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitleColor(Colors.customPink.color, for: .normal)
		button.setTitle(Localization.edit, for: .normal)
		return button
	}()
	
	private lazy var emailLabel = buildUserInfoLabel()
	private var model: UserHeaderModel?
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
	
	//MARK: - Overriden methods
	override func setNeedsLayout() {
		super.setNeedsLayout()
		userImage.rounded(userImage.frame.width / 2)
		userImage.layer.borderWidth = Constants.basicBorderWidth
		userImage.layer.borderColor = Colors.customPink.color.cgColor
	}
	
	//MARK: - Public methods
	func configure(with model: UserHeaderModel) {
		self.model = model
		emailLabel.text = model.email
		updateImage(model: model)
	}
}

//MARK: - Private extension
private extension HeaderCell {
	func setupUI() {
		addSubview(userImage)
		addSubview(editButton)
		addSubview(emailLabel)
		setupConstraints()
		rounded(Constants.basicCornerRadius)
		self.backgroundColor = Colors.darkNavyBlue.color
		self.layer.masksToBounds = true
		self.clipsToBounds = true
		emailLabel.textColor = .white
	}
	
	func setupConstraints() {
		userImage.heightAnchor.constraint(equalToConstant: Constants.basicImageViewBound)
			.isActive = true
		userImage.widthAnchor.constraint(equalToConstant: Constants.basicImageViewBound)
			.isActive = true
		userImage.topAnchor.constraint(equalTo: topAnchor,
									   constant: Constants.basicEdgeInsets)
		.isActive = true
		userImage.centerXAnchor.constraint(equalTo: centerXAnchor)
			.isActive = true
		editButton.topAnchor.constraint(equalTo: userImage.bottomAnchor,
										constant: Constants.basicTopInset)
		.isActive = true
		editButton.centerXAnchor.constraint(equalTo: centerXAnchor)
			.isActive = true
		emailLabel.topAnchor.constraint(equalTo: editButton.bottomAnchor)
			.isActive = true
		emailLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
			.isActive = true
	}
	
	func updateImage(model: UserHeaderModel) {
		switch model.image {
		case .url(let url):
			userImage.setImage(url)
		case .data(let data):
			userImage.setImage(data)
		case .asset(let asset):
			userImage.setImage(asset)
		case .none:
			break
		}
	}
}

extension HeaderCell: SelfConfiguringCell {
	static var reuseID: String {
		return "headerCell"
	}
}
extension HeaderCell: UIElementsBuilder {}

//MARK: - Constants
fileprivate enum Constants {
	static let basicBorderWidth: CGFloat = 1.0
	static let basicCornerRadius: CGFloat = 12
	static let basicImageViewBound: CGFloat = 86
	static let basicEdgeInsets: CGFloat = 16
	static let basicTopInset: CGFloat = 8
}
