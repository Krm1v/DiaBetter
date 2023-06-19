//
//  HeaderCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.03.2023.
//

import UIKit
import Combine

enum HeaderCellActions {
	case editButtonDidTapped
}

final class HeaderCell: BaseCollectionViewCell {
	//MARK: - UI Elements
	private lazy var userImage = UIImageView()
	private lazy var editButton = UIButton()
	private lazy var emailLabel = buildUserInfoLabel()
	
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<HeaderCellActions, Never>()
	
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
		self.layoutIfNeeded()
		emailLabel.text = model.email
		updateImage(model: model)
		setupBindings()
	}
}

//MARK: - Private extension
private extension HeaderCell {
	func setupUI() {
		addSubview(userImage, constraints: [
			userImage.heightAnchor.constraint(equalToConstant: Constants.basicImageViewBound),
			userImage.widthAnchor.constraint(equalToConstant: Constants.basicImageViewBound),
			userImage.topAnchor.constraint(equalTo: topAnchor,
										   constant: Constants.basicEdgeInsets),
			userImage.centerXAnchor.constraint(equalTo: centerXAnchor),
		])
		
		addSubview(editButton, constraints: [
			editButton.topAnchor.constraint(equalTo: userImage.bottomAnchor,
											constant: Constants.basicTopInset),
			editButton.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
		
		addSubview(emailLabel, constraints: [
			emailLabel.topAnchor.constraint(equalTo: editButton.bottomAnchor),
			emailLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
		
		self.rounded(Constants.basicCornerRadius)
		self.layer.masksToBounds = true
		self.clipsToBounds = true
		self.backgroundColor = Colors.darkNavyBlue.color
		userImage.layer.masksToBounds = false
		userImage.clipsToBounds = true
		userImage.image = Assets.userImagePlaceholder.image
		userImage.contentMode = .scaleToFill
		emailLabel.textColor = .white
		editButton.setTitleColor(Colors.customPink.color, for: .normal)
		editButton.setTitle(Localization.edit, for: .normal)
		editButton.titleLabel?.font = FontFamily.Montserrat.regular.font(size: Constants.editButtonFontSize)
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
	
	func setupBindings() {
		editButton.tapPublisher
			.map { HeaderCellActions.editButtonDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let basicBorderWidth:    CGFloat = 1.0
	static let basicCornerRadius: 	CGFloat = 12
	static let basicImageViewBound: CGFloat = 86
	static let basicEdgeInsets: 	CGFloat = 16
	static let basicTopInset: 	    CGFloat = 8
	static let editButtonFontSize: 	CGFloat = 13
}
