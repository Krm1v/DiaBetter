//
//  CarbsUnitsCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.06.2023.
//

import UIKit
import Combine

enum CarbsUnitsCellActions {
	case menuDidTapped(SettingsUnits.CarbsUnits)
}

final class CarbsUnitsCell: BaseCollectionViewCell {
	// MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel()
	private lazy var menuButton = UIButton()
	private lazy var menu = UIMenu()
	private var menuContent = SettingsUnits.CarbsUnits.allCases
	private var currentMenuItem: SettingsUnits.CarbsUnits?

	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<CarbsUnitsCellActions, Never>()

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
	func configure(_ model: CarbsUnitsCellModel) {
		titleLabel.text = model.title
		currentMenuItem = model.currentUnit
		menuButton.setTitle(currentMenuItem?.description, for: .normal)
	}
}

// MARK: - Private extension
private extension CarbsUnitsCell {
	func setupUI() {
		self.backgroundColor = .black
		rounded(12)
		titleLabel.font = FontFamily.Montserrat.regular.font(size: 15)
		menuButton.titleLabel?.font = FontFamily.Montserrat.regular.font(size: 15)
		menuButton.tintColor = .white
		menuButton.showsMenuAsPrimaryAction = true
		setupUIMenu()
		setupLayout()
	}

	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.centerYAnchor.constraint(
				equalTo: self.centerYAnchor),
			titleLabel.leadingAnchor.constraint(
				equalTo: self.leadingAnchor,
				constant: 16)])

		addSubview(menuButton, constraints: [
			menuButton.centerYAnchor.constraint(
				equalTo: self.centerYAnchor),
			menuButton.trailingAnchor.constraint(
				equalTo: self.trailingAnchor,
				constant: -16)])
	}

	func setupUIMenu() {
		let menuItems = menuContent.map { item in
			UIAction(title: item.description) { [unowned self] _ in
				self.menuButton.setTitle(item.description, for: .normal)
				actionSubject.send(.menuDidTapped(item))
			}
		}
		menu = UIMenu(children: menuItems)
		menuButton.menu = menu
	}
}
