//
//  GlucoseUnitsCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.06.2023.
//

import UIKit
import Combine

enum GlucoseUnitsCellActions {
	case segmentedControlValueDidChanged(SettingsUnits.GlucoseUnitsState)
}

final class GlucoseUnitsCell: BaseCollectionViewCell {
	// MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel()
	private lazy var segmentedControl = UISegmentedControl()

	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<GlucoseUnitsCellActions, Never>()
	private let allUnits = SettingsUnits.GlucoseUnitsState.allCases

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
	func configure(_ model: GlucoseUnitsCellModel) {
		titleLabel.text = model.title
		segmentedControl.selectedSegmentIndex = model.currentUnit.rawValue
		bindActions()
	}
}

// MARK: - Private extension
private extension GlucoseUnitsCell {
	func setupUI() {
		backgroundColor = Colors.darkNavyBlue.color
		rounded(12)
		titleLabel.font = FontFamily.Montserrat.regular.font(size: 15)
		segmentedControl.selectedSegmentTintColor = Colors.customPink.color
		for unit in allUnits {
			segmentedControl.insertSegment(withTitle: unit.title,
										   at: unit.rawValue,
										   animated: false)
		}
		setupLayout()
	}

	func setupLayout() {
		addSubview(
			titleLabel,
			constraints: [
				titleLabel.centerYAnchor.constraint(
					equalTo: self.centerYAnchor),
				titleLabel.leadingAnchor.constraint(
					equalTo: self.leadingAnchor,
					constant: 8)])

		addSubview(
			segmentedControl,
			constraints: [
				segmentedControl.centerYAnchor.constraint(
					equalTo: self.centerYAnchor),
				segmentedControl.trailingAnchor.constraint(
					equalTo: self.trailingAnchor,
					constant: -8),
				segmentedControl.widthAnchor.constraint(
					equalToConstant: self.frame.width / 3)])
	}

	func bindActions() {
		segmentedControl.selectedSegmentIndexPublisher
			.compactMap { SettingsUnits.GlucoseUnitsState(rawValue: $0) }
			.map { GlucoseUnitsCellActions.segmentedControlValueDidChanged($0) }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}
