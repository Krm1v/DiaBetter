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
	private lazy var titleLabel = buildTitleLabel(fontSize: 25)
	private lazy var datePicker = UIDatePicker()
	
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
	
	//MARK: - Public methods
	func configure(model: DatePickerCellModel) {
		titleLabel.text = model.title
	}
}

//MARK: - Private extension
private extension DatePickerCell {
	func setupUI() {
		backgroundColor = Colors.darkNavyBlue.color
		rounded(12)
		setupLayout()
		datePicker.preferredDatePickerStyle = .compact
		datePicker.tintColor = Colors.customPink.color
	}
	
	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
		])
		addSubview(datePicker, constraints: [
			datePicker.centerYAnchor.constraint(equalTo: centerYAnchor),
			datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
		])
	}
	
	func setupBindings() {
		datePicker.datePublisher
			.sink { [unowned self] date in
				actionSubject.send(.dateDidChanged(date))
			}
			.store(in: &cancellables)
	}
}

//MARK: - Extension SelfConfiguringCell
extension DatePickerCell: SelfConfiguringCell {
	static var reuseID: String {
		"datePickerCell"
	}
}

//MARK: - Extension UIElementsBuilder
extension DatePickerCell: UIElementsBuilder {}

