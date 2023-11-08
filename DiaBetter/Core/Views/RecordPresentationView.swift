//
//  BoxElementEditableView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.06.2023.
//

import UIKit
import Combine

enum RecordPresentationViewActions {
	case textfieldDidChanged(String?)
}

final class RecordPresentationView: UIView {
	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<RecordPresentationViewActions, Never>()
	private var cancellables = Set<AnyCancellable>()

	var isEditing: Bool = false {
		didSet { isEditing ? setupEditLayout() : setupShowLayout() }
	}

	var titleText: String? {
		get { titleLabel.text }
		set { titleLabel.text = newValue }
	}

	var valueText: String? {
		get { valueLabel.text }
		set { valueLabel.text = newValue }
	}

	// MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel(fontSize: Constants.defaultFontSize,
													   textAllignment: .natural)
	private lazy var valueLabel = buildUserInfoLabel()
	private lazy var editTextField = buildSystemTextField(keyBoardType: .decimalPad,
														  capitalization: .none)

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupShowLayout()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupShowLayout()
	}

	// MARK: - Public methods
	func setupShowLayout() {
		editTextField.isHidden = true
		valueLabel.isHidden.toggle()
	}

	func setupEditLayout() {
		valueLabel.isHidden = true
		editTextField.isHidden.toggle()
	}

	// MARK: - Deinit
	deinit {
		cancellables.removeAll()
	}
}

// MARK: - Private extension
private extension RecordPresentationView {
	func setupUI() {
		self.rounded(Constants.defaultCornerRadius)
		self.backgroundColor = Colors.darkNavyBlue.color
		setupLayout()
		setupBindings()
	}

	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
												constant: Constants.defaultSmallEdgeInset)
		])

		addSubview(valueLabel, constraints: [
			valueLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			valueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
												 constant: -Constants.defaultLargeEdgeInset)
		])

		addSubview(editTextField, constraints: [
			editTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
			editTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor,
													constant: -Constants.defaultLargeEdgeInset)
		])
	}

	func setupBindings() {
		editTextField.textPublisher
			.replaceEmpty(with: nil)
			.map { RecordPresentationViewActions.textfieldDidChanged($0) }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}

// MARK: - Extension UIElementsBuilder
extension RecordPresentationView: UIElementsBuilder { }

// MARK: - Constants
private enum Constants {
	static let defaultFontSize: CGFloat = 17
	static let defaultCornerRadius: CGFloat = 12
	static let defaultSmallEdgeInset: CGFloat = 8
	static let defaultLargeEdgeInset: CGFloat = 16
}
