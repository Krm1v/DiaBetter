//
//  BackupDateCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.07.2023.
//

import UIKit
import Combine

enum BackupDateCellActions {
	case datePickerValueDidChanged(Date)
}

final class BackupDateCell: BaseCollectionViewCell {
	// MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel(fontSize: 15)
	private lazy var datePicker = UIDatePicker()

	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<BackupDateCellActions, Never>()

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
	func configure(_ model: BackupDateCellModel) {
		titleLabel.text = model.title
		datePicker.date = model.date
		bindActions()
	}
}

// MARK: - Private extension
private extension BackupDateCell {
	func setupUI() {
		self.backgroundColor = .black
		self.rounded(12)
		titleLabel.font = FontFamily.Montserrat.regular.font(size: 15)
		datePicker.datePickerMode = .date
		datePicker.preferredDatePickerStyle = .compact
		datePicker.tintColor = Colors.customPink.color
		datePicker.maximumDate = .now
		setupLayout()
	}

	func setupLayout() {
		addSubview(
			titleLabel,
			constraints: [
				titleLabel.leadingAnchor.constraint(
					equalTo: self.leadingAnchor,
					constant: 16),

				titleLabel.centerYAnchor.constraint(
					equalTo: self.centerYAnchor)])

		addSubview(
			datePicker,
			constraints: [
				datePicker.trailingAnchor.constraint(
					equalTo: self.trailingAnchor,
					constant: -16),

				datePicker.centerYAnchor.constraint(
					equalTo: self.centerYAnchor)])
	}

	func bindActions() {
		datePicker.datePublisher
			.map { BackupDateCellActions.datePickerValueDidChanged($0) }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}
