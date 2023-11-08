//
//  PlainCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.04.2023.
//

import UIKit
import Combine

enum GlucoseOrMealCellActions {
	case textFieldValueDidChanged(String)
}

final class GlucoseLevelOrMealCell: BaseCollectionViewCell {
	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<GlucoseOrMealCellActions, Never>()

	// MARK: - UI Elements
	private lazy var title = buildFieldTitleLabel()
	private lazy var textField = buildSystemTextField(with: "", keyBoardType: .decimalPad)
	private lazy var unitsLabel = buildUserInfoLabel()
	private lazy var hStack = buildStackView(axis: .horizontal,
											 alignment: .fill,
											 distribution: .fill,
											 spacing: Constants.defaultStackViewSpacing)

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
	func configure(with model: GlucoseLevelOrMealCellModel) {
		title.text = model.title
		textField.placeholder = model.textfieldValue
		unitsLabel.text = model.unitsTitle
		setupBindings()
	}
}

// MARK: - Private extension
private extension GlucoseLevelOrMealCell {
	func setupUI() {
		setupLayout()
		self.rounded(Constants.defaultCornerRadius)
		self.backgroundColor = Colors.darkNavyBlue.color
		textField.borderStyle = .none
	}

	func setupLayout() {
		addSubview(
			hStack,
			constraints: [
				hStack.leadingAnchor.constraint(
					equalTo: leadingAnchor,
					constant: Constants.defaultLargeEdgeInset),

				hStack.trailingAnchor.constraint(
					equalTo: trailingAnchor,
					constant: -Constants.defaultLargeEdgeInset),

				hStack.centerYAnchor.constraint(equalTo: self.centerYAnchor)])

		[title, textField, unitsLabel].forEach { hStack.addArrangedSubview($0) }
	}

	func setupBindings() {
		textField.textPublisher
			.sink { [unowned self] text in
				guard let text = text else {
					return
				}
				actionSubject.send(.textFieldValueDidChanged(text))
			}
			.store(in: &cancellables)
	}
}

// MARK: - Constants
private enum Constants {
	static let defaultStackViewSpacing: CGFloat = 8
	static let defaultSmallEdgeInset: 	CGFloat = 8
	static let defaultLargeEdgeInset: 	CGFloat = 16
	static let defaultCornerRadius: 	CGFloat = 12
}
