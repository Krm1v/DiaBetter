//
//  SwitcherCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import UIKit
import Combine

enum SwitcherCellActions {
	case switcherDidToggled(Bool)
}

final class SwitcherCell: BaseTableViewCell {
	// MARK: - UI Elements
	private lazy var switcher = UISwitch()
	private lazy var hStack = buildStackView(axis: .horizontal,
											 alignment: .center,
											 distribution: .fill,
											 spacing: .zero)
	private lazy var titleLabel = buildFieldTitleLabel(with: "", fontSize: 15)

	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<SwitcherCellActions, Never>()

	// MARK: - Init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}

	// MARK: - Public methods
	func configure(_ model: SwitcherCellModel) {
		titleLabel.text = model.title
		switcher.isOn = model.isOn
		setupBindings()
	}
}

// MARK: - Private extension
private extension SwitcherCell {
	func setupUI() {
		backgroundColor = Colors.darkNavyBlue.color
		selectionStyle = .none
		switcher.onTintColor = Colors.customPink.color
		setupLayout()
		titleLabel.font = FontFamily.SFProRounded.regular.font(size: 15)
	}

	func setupLayout() {
		contentView.addSubview(hStack, constraints: [
			hStack.topAnchor.constraint(equalTo: self.topAnchor),

			hStack.leadingAnchor.constraint(
				equalTo: self.leadingAnchor,
				constant: 16),

			hStack.trailingAnchor.constraint(
				equalTo: self.trailingAnchor,
				constant: -16),
			
			hStack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])

		[titleLabel, switcher].forEach { hStack.addArrangedSubview($0) }
	}

	func setupBindings() {
		switcher.isOnPublisher
			.map { SwitcherCellActions.switcherDidToggled($0) }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}
