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
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = CurrentValueSubject<InsulinCellActions?, Never>(nil)
	
	//MARK: - UI Elements
	private lazy var titleLabel = buildTitleLabel(fontSize: 25)
	private lazy var fastInsulinParameterTitle = buildFieldTitleLabel(fontSize: 20)
	private lazy var basalInsulinParameterTitle = buildFieldTitleLabel(fontSize: 20)
	private lazy var fastInsulinTextfield = buildSystemTextField(with: "", keyBoardType: .decimalPad)
	private lazy var basalInsulinTextfield = buildSystemTextField(with: "", keyBoardType: .decimalPad)
	private lazy var unitsLabelForFastInsulin = buildUserInfoLabel()
	private lazy var unitsLabelForBasalInsulin = buildUserInfoLabel()
	private lazy var hStackForFastInsulin = buildStackView(axis: .horizontal,
														   alignment: .fill,
														   distribution: .fill,
														   spacing: 8)
	private lazy var hStackForBasalInsulin = buildStackView(axis: .horizontal,
															alignment: .fill,
															distribution: .fill,
															spacing: 8)
	private lazy var vStack = buildStackView(axis: .vertical,
											 alignment: .fill,
											 distribution: .fillProportionally,
											 spacing: 20)
	
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
	
	func configure(with model: InsulinCellModel) {
		titleLabel.text = model.title
		fastInsulinParameterTitle.text = model.parameterTitleForFastInsulin
		basalInsulinParameterTitle.text = model.parameterTitleForBasalInsulin
		fastInsulinTextfield.placeholder = model.fastInsulinTextfieldValue
		basalInsulinTextfield.placeholder = model.basalInsulinTextFieldValue
		unitsLabelForFastInsulin.text = model.unitsTitleForFastInsulin
		unitsLabelForBasalInsulin.text = model.unitsTitleForBasalInsulin
	}
}

//MARK: - Private extension
private extension InsulinCell {
	func setupUI() {
		backgroundColor = Colors.darkNavyBlue.color
		fastInsulinTextfield.borderStyle = .none
		basalInsulinTextfield.borderStyle = .none
		self.rounded(12)
		setupLayout()
	}
	
	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
		])
		addSubview(vStack, constraints: [
			vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
			vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
		])
		[fastInsulinParameterTitle, fastInsulinTextfield, unitsLabelForFastInsulin].forEach {
			hStackForFastInsulin.addArrangedSubview($0)
		}
		[basalInsulinParameterTitle, basalInsulinTextfield, unitsLabelForBasalInsulin].forEach { hStackForBasalInsulin.addArrangedSubview($0) }
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

//MARK: - Extension SelfConfiguringCell
extension InsulinCell: SelfConfiguringCell {
	static var reuseID: String {
		"insulinCell"
	}
}

//MARK: - Extension UIElementsBuilder
extension InsulinCell: UIElementsBuilder {}
