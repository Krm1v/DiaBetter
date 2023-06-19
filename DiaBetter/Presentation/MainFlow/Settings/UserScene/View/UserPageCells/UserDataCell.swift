//
//  UserDataCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.03.2023.
//

import UIKit
import Combine

enum UserDataCellActions {
	case textFieldDidChanged(String)
}

final class UserDataCell: BaseCollectionViewCell {
	//MARK: - Properties
	private(set) lazy var userDataCellEventsPublisher = userDataCellEventsSubject.eraseToAnyPublisher()
	private let userDataCellEventsSubject = PassthroughSubject<UserDataCellActions, Never>()
	
	//MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel()
	private lazy var userTextField = UITextField()
	
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
		setupEvents()
	}
}

//MARK: - Private extension
private extension UserDataCell {
	func setupUI() {
		titleLabel.textColor = .white
		self.backgroundColor = Colors.darkNavyBlue.color
		addSubs()
		userTextField.borderStyle = .none
		userTextField.font = FontFamily.Montserrat.regular.font(size: Constants.userTextFieldDefaultFontSize)
	}
	
	func addSubs() {
		addSubview(titleLabel, constraints: [
			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
												constant: Constants.basicSmallEdgeInset)
		])
		
		addSubview(userTextField, constraints: [
			userTextField.trailingAnchor.constraint(equalTo: trailingAnchor,
													constant: -Constants.basicSmallEdgeInset),
			userTextField.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
	
	func setupEvents() {
		userTextField.textPublisher
			.replaceNil(with: "")
			.map { UserDataCellActions.textFieldDidChanged($0) }
			.subscribe(userDataCellEventsSubject)
			.store(in: &cancellables)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let basicLargeEdgeInset: 		 CGFloat = 16
	static let basicSmallEdgeInset: 		 CGFloat = 8
	static let basicCornerRadius: 			 CGFloat = 20
	static let userTextFieldDefaultFontSize: CGFloat = 17
}

