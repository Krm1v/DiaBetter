//
//  ReminderCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import UIKit
import Combine

enum ReminderCellAction {
	case datePickerValueDidChanged(Date)
}

final class ReminderCell: BaseTableViewCell {
	//MARK: - UI Elements
	private lazy var hStack = buildStackView(axis: .horizontal,
											 alignment: .center,
											 distribution: .fill,
											 spacing: .zero)
	private lazy var titleLabel = buildFieldTitleLabel(with: "",
													   fontSize: Constants.defaultFontSize,
													   textAllignment: .natural)
	private lazy var datePicker = UIDatePicker()
	
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<ReminderCellAction, Never>()
	
	//MARK: - Init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
//		bindActions()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
//		bindActions()
	}
	
	//MARK: - Public methods
	func configure(_ model: ReminderCellModel) {
		titleLabel.text = model.title
		if let date = model.date {
			datePicker.date = date
		}
		bindActions()
	}
}

//MARK: - Private extension
private extension ReminderCell {
	func setupUI() {
		backgroundColor = Colors.darkNavyBlue.color
		titleLabel.font = FontFamily.Montserrat.regular.font(size: Constants.smallFontSize)
		datePicker.datePickerMode = .time
		datePicker.preferredDatePickerStyle = .compact
		setupLayout()
	}
	
	func setupLayout() {
		contentView.addSubview(hStack, constraints: [
			hStack.leadingAnchor.constraint(equalTo: self.leadingAnchor,
											constant: Constants.defaultEdgeInset),
			hStack.trailingAnchor.constraint(equalTo: self.trailingAnchor,
											 constant: -Constants.defaultEdgeInset),
			hStack.heightAnchor.constraint(equalToConstant: self.frame.width / Constants.defaultStackHeightMultiplier)
		])
		
		[titleLabel, datePicker].forEach { hStack.addArrangedSubview($0) }
	}
	
	func bindActions() {
		datePicker.datePublisher
			.map { ReminderCellAction.datePickerValueDidChanged($0) }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let defaultFontSize:  			 CGFloat = 17
	static let smallFontSize: 	 			 CGFloat = 13
	static let defaultEdgeInset: 		 	 CGFloat = 16
	static let defaultStackHeightMultiplier: CGFloat = 7
}
