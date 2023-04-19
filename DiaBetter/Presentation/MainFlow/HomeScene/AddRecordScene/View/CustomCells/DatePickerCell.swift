//
//  ButtonsCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.04.2023.
//

import UIKit
import Combine

final class DatePickerCell: UICollectionViewCell {
	//MARK: - Properties
	
	
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
	
	//MARK: - Overriden methods
	override func prepareForReuse() {
		super.prepareForReuse()
//		cancellables.removeAll()
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
	}
	
	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
		])
		addSubview(datePicker, constraints: [
			datePicker.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
		])
	}
	
	func setupBindings() {
		
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

