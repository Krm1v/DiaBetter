//
//  InsulinCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.04.2023.
//

import UIKit
import Combine

enum InsulinCellActions {
	case fastInsulinTextfieldDidChanged(String)
	case basalInsulinTextfieldDidChanged(String)
}

final class InsulinCell: BaseCollectionViewCell {
	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<InsulinCellActions, Never>()

	// MARK: - UI Elements
	private lazy var titleLabel = buildTitleLabel(fontSize: Constants.titleLabelFontSize)
	private lazy var fastInsulinParameterTitle = buildFieldTitleLabel(fontSize: Constants.parameterTitleFontSize)
	private lazy var basalInsulinParameterTitle = buildFieldTitleLabel(fontSize: Constants.parameterTitleFontSize)
	private lazy var fastInsulinTextfield = buildSystemTextField(with: "", keyBoardType: .decimalPad)
	private lazy var basalInsulinTextfield = buildSystemTextField(with: "", keyBoardType: .decimalPad)
	private lazy var unitsLabelForFastInsulin = buildUserInfoLabel()
	private lazy var unitsLabelForBasalInsulin = buildUserInfoLabel()
	private lazy var hStackForFastInsulin = buildStackView(axis: .horizontal,
														   alignment: .fill,
														   distribution: .fill,
														   spacing: Constants.stackViewSmallSpacing)
	private lazy var hStackForBasalInsulin = buildStackView(axis: .horizontal,
															alignment: .fill,
															distribution: .fill,
															spacing: Constants.stackViewSmallSpacing)
	private lazy var vStack = buildStackView(axis: .vertical,
											 alignment: .fill,
											 distribution: .fillProportionally,
											 spacing: Constants.stackViewLargeSpacing)

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
	func configure(with model: InsulinCellModel) {
		titleLabel.text = model.title
		fastInsulinParameterTitle.text = model.parameterTitleForFastInsulin
		basalInsulinParameterTitle.text = model.parameterTitleForBasalInsulin
		fastInsulinTextfield.placeholder = model.fastInsulinTextfieldValue
		basalInsulinTextfield.placeholder = model.basalInsulinTextFieldValue
		unitsLabelForFastInsulin.text = model.unitsTitleForFastInsulin
		unitsLabelForBasalInsulin.text = model.unitsTitleForBasalInsulin
		setupBindings()
	}
}

// MARK: - Private extension
private extension InsulinCell {
	func setupUI() {
		setupLayout()
		self.rounded(Constants.defaultCornerRadius)
		self.backgroundColor = Colors.darkNavyBlue.color
		fastInsulinTextfield.borderStyle = .none
		basalInsulinTextfield.borderStyle = .none
	}

	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: Constants.smallEdgeInset),

			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: Constants.smallEdgeInset)
		])

		addSubview(vStack, constraints: [
			vStack.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: Constants.largeEdgeInset),

			vStack.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -Constants.largeEdgeInset),

			vStack.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -Constants.smallEdgeInset)
		])

		[fastInsulinParameterTitle, fastInsulinTextfield, unitsLabelForFastInsulin].forEach {
			hStackForFastInsulin.addArrangedSubview($0)
		}
		[basalInsulinParameterTitle, basalInsulinTextfield, unitsLabelForBasalInsulin].forEach {
			hStackForBasalInsulin.addArrangedSubview($0)
		}

		[hStackForFastInsulin, hStackForBasalInsulin].forEach { vStack.addArrangedSubview($0) }
	}

	func setupBindings() {
		fastInsulinTextfield.textPublisher
			.sink { [unowned self] text in
				guard let text = text else {
					return
				}
				self.actionSubject.send(.fastInsulinTextfieldDidChanged(text))
			}
			.store(in: &cancellables)

		basalInsulinTextfield.textPublisher
			.sink { [unowned self] text in
				guard let text = text else {
					return
				}
				self.actionSubject.send(.basalInsulinTextfieldDidChanged(text))
			}
			.store(in: &cancellables)
	}
}

// MARK: - Constants
private enum Constants {
	static let titleLabelFontSize: 	   CGFloat = 25
	static let parameterTitleFontSize: CGFloat = 20
	static let stackViewSmallSpacing:  CGFloat = 8
	static let stackViewLargeSpacing:  CGFloat = 20
	static let defaultCornerRadius:    CGFloat = 12
	static let smallEdgeInset: 		   CGFloat = 8
	static let largeEdgeInset: 		   CGFloat = 16
}
