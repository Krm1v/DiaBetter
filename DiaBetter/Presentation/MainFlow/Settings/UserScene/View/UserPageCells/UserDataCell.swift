//
//  UserDataCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.03.2023.
//

import UIKit
import Combine

enum UserDataCellEvents {
	case textFieldDidChanged(String)
}

final class UserDataCell: BaseCollectionViewCell {
	//MARK: - Properties
	private(set) lazy var userDataCellEventsPublisher = userDataCellEventsSubject.eraseToAnyPublisher()
	private let userDataCellEventsSubject = PassthroughSubject<UserDataCellEvents, Never>()

	//MARK: - UI Elements
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
		setupEvents()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupEvents()
	}
	
	//MARK: - Public methods
	func configure(with model: UserDataSettingsModel) {
		titleLabel.text = model.title
		userTextField.text = model.textFieldValue
	}
	
	func setupEvents() {
		userTextField.textPublisher
			.sink { [weak self] text in
				guard let self = self else { return }
				guard let text = text else { return }
				self.userDataCellEventsSubject.send(.textFieldDidChanged(text))
			}
			.store(in: &cancellables)
	}
}

//MARK: - Private extension
private extension UserDataCell {
	func setupUI() {
		backgroundColor = Colors.darkNavyBlue.color
		titleLabel.textColor = .white
		addSubs()
		setupConstraints()
	}
	
	func addSubs() {
		addSubview(titleLabel)
		addSubview(userTextField)
	}
	
	func setupConstraints() {
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

//MARK: - Extension SelfConfiguringCollectionViewCell
extension UserDataCell: UIElementsBuilder {}
extension UserDataCell: SelfConfiguringCell {
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

