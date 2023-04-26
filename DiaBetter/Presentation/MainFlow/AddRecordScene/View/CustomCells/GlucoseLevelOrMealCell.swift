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
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = CurrentValueSubject<GlucoseOrMealCellActions?, Never>(nil)
	
	//MARK: - UI Elements
	private lazy var titleLabel = buildTitleLabel(fontSize: 25)
	private lazy var parameterTitle = buildFieldTitleLabel(fontSize: 20)
	private lazy var textField = buildSystemTextField(with: "", keyBoardType: .decimalPad)
	private lazy var unitsLabel = buildUserInfoLabel()
	private lazy var hStack = buildStackView(axis: .horizontal,
											 alignment: .fill,
											 distribution: .fill,
											 spacing: 8)
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupBindings()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupBindings()
	}
	
	func configure(with model: GlucoseLevelOrMealCellModel) {
		titleLabel.text = model.title
		parameterTitle.text = model.parameterTitle
		textField.placeholder = model.textfieldValue
		unitsLabel.text = model.unitsTitle
	}
}

//MARK: - Private extension
private extension GlucoseLevelOrMealCell {
	func setupUI() {
		backgroundColor = Colors.darkNavyBlue.color
		textField.borderStyle = .none
		self.rounded(12)
		setupLayout()
	}
	
	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
		])
		addSubview(hStack, constraints: [
			hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
		])
		[parameterTitle, textField, unitsLabel].forEach { hStack.addArrangedSubview($0) }
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

//MARK: - Extension SelfConfiguringCell
extension GlucoseLevelOrMealCell: SelfConfiguringCell {
	static var reuseID: String {
		"plainCell"
	}
}

//MARK: - Extension UIElementsBuilder
extension GlucoseLevelOrMealCell: UIElementsBuilder {}
