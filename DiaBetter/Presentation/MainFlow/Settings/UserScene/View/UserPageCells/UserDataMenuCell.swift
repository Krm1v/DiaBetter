//
//  UserDataMenuCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.04.2023.
//

import UIKit
import Combine

enum UserDataMenuCellEvents {
	case menuDidTapped
	case userParameterDidChanged(String)
}

final class UserDataMenuCell: UICollectionViewCell {
	//MARK: - Properties
	private(set) lazy var userDataMenuPublisher = userDataMenuSubject.eraseToAnyPublisher()
	private let userDataMenuSubject = PassthroughSubject<UserDataMenuCellEvents, Never>()
	private var cancellables = Set<AnyCancellable>()
	private var menuDatasource = [SettingsMenuDatasourceProtocol]()
	
	//MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel()
	private lazy var userParameterButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = FontFamily.Montserrat.regular.font(size: 17)
		button.tintColor = .white
		button.showsMenuAsPrimaryAction = true
		return button
	}()
	
	private var menu = UIMenu()
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		bindActions()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		bindActions()
	}
	
	//MARK: - Overriden methods
	override func prepareForReuse() {
		super.prepareForReuse()
		cancellables.removeAll()
	}
	
	//MARK: - Public methods
	func configure(with model: UserDataMenuSettingsModel) {
		titleLabel.text = model.title
		userParameterButton.setTitle(model.labelValue, for: .normal)
		switch model.source {
		case .diabetesType:
			menuDatasource = DiabetesType.allCases
		case .longInsulines:
			menuDatasource = LongInsulines.allCases
		case .fastInsulines:
			menuDatasource = FastInsulines.allCases
		}
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

//MARK: - Private extension
private extension UserDataMenuCell {
	func setupUI() {
		backgroundColor = Colors.darkNavyBlue.color
		addSubs()
		setupLayout()
		titleLabel.textColor = .white
	}
	
	func addSubs() {
		addSubview(titleLabel)
		addSubview(userParameterButton)
	}
	
	func setupLayout() {
		titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
			.isActive = true
		titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
			.isActive = true
		userParameterButton.centerYAnchor.constraint(equalTo: centerYAnchor)
			.isActive = true
		userParameterButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
			.isActive = true
	}
	
	func presentPopover(with datasource: [SettingsMenuDatasourceProtocol]) {
		var menuItems = [UIAction]()
		let _ = datasource.map { item in
			let action = UIAction(title: item.title) { [weak self] _ in
				guard let self = self else { return }
				self.userParameterButton.setTitle(item.title, for: .normal)
				self.userDataMenuSubject.send(.userParameterDidChanged(item.title))
			}
			menuItems.append(action)
		}
		menu = UIMenu(title: "", children: menuItems)
		userParameterButton.showsMenuAsPrimaryAction = true
		userParameterButton.menu = menu
	}
}

//MARK: - Extension UIElementsBuilder
extension UserDataMenuCell: UIElementsBuilder {}

//MARK: - Extension SelfConfiguringCollectionViewCell
extension UserDataMenuCell: SelfConfiguringCell {
	static var reuseID: String {
		return "userDataMenuCell"
	}
}
