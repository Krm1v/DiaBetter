//
//  UserDataMenuCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.04.2023.
//

import UIKit
import Combine

enum UserDataMenuCellActions {
	case menuDidTapped(UserParametersProtocol)
}

final class UserDataMenuCell: BaseCollectionViewCell {
	// MARK: - Properties
	private(set) lazy var userDataMenuPublisher = userDataMenuSubject.eraseToAnyPublisher()
	private let userDataMenuSubject = PassthroughSubject<UserDataMenuCellActions, Never>()
	private var menuDatasource: [UserParametersProtocol] = []

	// MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel()
	private lazy var userParameterButton = UIButton()
	private var menu = UIMenu()

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
	func configure(with model: UserDataMenuSettingsModel) {
		debugPrint(model)
		titleLabel.text = model.rowTitle
		userParameterButton.setTitle(model.labelValue, for: .normal)
		menuDatasource = model.source.items
		setupUIMenu()
	}
}

// MARK: - Private extension
private extension UserDataMenuCell {
	func setupUI() {
		titleLabel.textColor = .white
		self.backgroundColor = .black
		titleLabel.font = FontFamily.Montserrat.regular.font(size: Constants.titleLabelDefaultFontSize)
		userParameterButton.titleLabel?.font = FontFamily.Montserrat.regular.font(size: Constants.titleLabelFontSize)
		userParameterButton.tintColor = .white
		userParameterButton.showsMenuAsPrimaryAction = true
		setupLayout()
	}

	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.centerYAnchor.constraint(
				equalTo: centerYAnchor),

			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: Constants.defaultEdgeInsets)])

		addSubview(userParameterButton, constraints: [
			userParameterButton.centerYAnchor.constraint(
				equalTo: centerYAnchor),

			userParameterButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -Constants.defaultEdgeInsets)])
	}

	func setupUIMenu() {
		let menuItems = menuDatasource.map { item in
			UIAction(title: item.title) { [unowned self] _ in
				self.userParameterButton.setTitle(item.title, for: .normal)
				self.userDataMenuSubject.send(.menuDidTapped(item))
			}
		}

		menu = UIMenu(children: menuItems)
		userParameterButton.menu = menu
	}
}

// MARK: - Constants
private enum Constants {
	static let titleLabelFontSize: 		  CGFloat = 15
	static let defaultEdgeInsets: 		  CGFloat = 16
	static let titleLabelDefaultFontSize: CGFloat = 15
}
