//
//  ButtonsCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.04.2023.
//

import UIKit
import Combine

enum DatePickerCellActions {
	case dateDidChanged(Date)
}

final class DatePickerCell: BaseCollectionViewCell {
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<DatePickerCellActions, Never>()
	
	//MARK: - UI Elements
	private lazy var titleLabel = buildTitleLabel(fontSize: Constants.titleLabelFontSize)
	private lazy var datePicker = UIDatePicker()
	
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
	func configure(model: DatePickerCellModel) {
		titleLabel.text = model.title
		setupBindings()
	}
}

//MARK: - Private extension
private extension DatePickerCell {
	func setupUI() {
		setupLayout()
		self.rounded(Constants.defaultCornerRadius)
		self.backgroundColor = Colors.darkNavyBlue.color
		datePicker.datePickerMode = .dateAndTime
		datePicker.preferredDatePickerStyle = .compact
		datePicker.tintColor = Colors.customPink.color
		datePicker.maximumDate = .now
	}
	
	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
												constant: Constants.smallEdgeInset)
		])
		addSubview(datePicker, constraints: [
			datePicker.centerYAnchor.constraint(equalTo: centerYAnchor),
			datePicker.trailingAnchor.constraint(equalTo: trailingAnchor,
												 constant: -Constants.smallEdgeInset)
		])
	}
	
	func setupBindings() {
		datePicker.datePublisher
			.map { DatePickerCellActions.dateDidChanged($0) }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let titleLabelFontSize:  CGFloat = 25
	static let defaultCornerRadius: CGFloat = 12
	static let smallEdgeInset: 		CGFloat = 8
}
