//
//  UserDataMenuCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.04.2023.
//

import UIKit
import Combine

enum UserDataMenuCellActions {
	case menuDidTapped
	case userParameterDidChanged(String)
}

final class UserDataMenuCell: BaseCollectionViewCell {
	//MARK: - Properties
	private(set) lazy var userDataMenuPublisher = userDataMenuSubject.eraseToAnyPublisher()
	private let userDataMenuSubject = PassthroughSubject<UserDataMenuCellActions, Never>()
	private var menuDatasource = [SettingsMenuDatasourceProtocol]()
	
	//MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel()
	private lazy var userParameterButton = UIButton()
	private var menu = UIMenu()
	
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
	func configure(with model: UserDataMenuSettingsModel) {
		titleLabel.text = model.title
		userParameterButton.setTitle(model.labelValue, for: .normal)
		switch model.source {
		case .diabetesType:
			menuDatasource = UserTreatmentSettings.DiabetesType.allCases
		case .longInsulines:
			menuDatasource = UserTreatmentSettings.LongInsulines.allCases
		case .fastInsulines:
			menuDatasource = UserTreatmentSettings.FastInsulines.allCases
		}
		bindActions()
	}
}

//MARK: - Private extension
private extension UserDataMenuCell {
	func setupUI() {
		setupLayout()
		titleLabel.textColor = .white
		self.backgroundColor = Colors.darkNavyBlue.color
		userParameterButton.titleLabel?.font = FontFamily.Montserrat.regular.font(size: Constants.titleLabelFontSize)
		userParameterButton.tintColor = .white
		userParameterButton.showsMenuAsPrimaryAction = true
	}
	
	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
												constant: Constants.defaultEdgeInsets)
		])
		
		addSubview(userParameterButton, constraints: [
			userParameterButton.centerYAnchor.constraint(equalTo: centerYAnchor),
			userParameterButton.trailingAnchor.constraint(equalTo: trailingAnchor,
														  constant: -Constants.defaultEdgeInsets)
		])
	}
	
	func presentPopover(with datasource: [SettingsMenuDatasourceProtocol]) {
		let menuItems = datasource.map { item in
			UIAction(title: item.title) { [unowned self] _ in
				self.userParameterButton.setTitle(item.title, for: .normal)
				self.userDataMenuSubject.send(.userParameterDidChanged(item.title))
			} }
		menu = UIMenu(title: "", children: menuItems)
		userParameterButton.showsMenuAsPrimaryAction = true
		userParameterButton.menu = menu
	}
	
	//MARK: - Actions
	func bindActions() {
		userParameterButton.tapPublisher
			.sink { [unowned self] in
				userDataMenuSubject.send(.menuDidTapped)
				presentPopover(with: menuDatasource)
			}
			.store(in: &cancellables)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let titleLabelFontSize: CGFloat = 17
	static let defaultEdgeInsets:  CGFloat = 8
}
