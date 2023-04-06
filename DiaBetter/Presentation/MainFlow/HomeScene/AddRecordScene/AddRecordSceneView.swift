//
//  AddRecordSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import UIKit
import Combine
import KeyboardLayoutGuide

enum AddRecordActions {
	case glucoseTextFieldDidChanged(String)
	case mealTextFieldDidChanged(String)
	case fastInsulinTextFieldChanged(String)
	case longInsulinTextFieldDidChanged(String)
	case noteTextViewDidChanged(String)
	case saveButtonPressed
	case closeButtonPressed
}

final class AddRecordSceneView: BaseView {
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<AddRecordActions, Never>()
	
	//MARK: - UIElements
	private let scrollView = AxisScrollView(axis: .vertical)
	private lazy var closeButton = buildBackButton(with: Localization.close)
	private lazy var saveButton = buildGradientButton(with: Localization.save, fontSize: 13)
	private lazy var dateLabel = buildUserInfoLabel()
	private lazy var glucoseTitleLabel = buildFieldTitleLabel(with: Localization.glucose)
	private lazy var mealTitleLabel = buildFieldTitleLabel(with: Localization.meal)
	private lazy var insulinTitleLabel = buildFieldTitleLabel(with: Localization.insulin)
	private lazy var notesTitleLabel = buildFieldTitleLabel(with: Localization.notes)
	private lazy var glucoseTextfield = buildSystemTextField(with: Localization.glucose,
															 keyBoardType: .decimalPad)
	private lazy var mealTextfield = buildSystemTextField(with: Localization.meal, keyBoardType: .decimalPad)
	private lazy var fastInsulinTextfield = buildSystemTextField(with: Localization.fastActingInsulin, keyBoardType: .decimalPad)
	private lazy var longInsulinTextfield = buildSystemTextField(with: Localization.basalInsulin, keyBoardType: .decimalPad)
	private lazy var mainStackView = buildStackView(axis: .vertical,
													alignment: .fill,
													distribution: .fill,
													spacing: 8)
	private lazy var vStackForButtons = buildStackView(axis: .vertical,
													   alignment: .fill,
													   distribution: .fillEqually,
													   spacing: 8)
	private lazy var notesTextField = buildSystemTextField(with: Localization.notes)
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupBindings()
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupBindings()
		setupUI()
	}
	
	//MARK: - Public methods
	func setupDateLabel(with date: String) {
		dateLabel.text = date
		dateLabel.font = .systemFont(ofSize: 17)
	}
}

//MARK: - Private extension
private extension AddRecordSceneView {
	func setupUI() {
		backgroundColor = .black
		addSubs()
		scrollView.delaysContentTouches = false
		glucoseTitleLabel.textColor = .red
		mealTitleLabel.textColor = .green
		insulinTitleLabel.textColor = .systemBlue
	}
	
	func addSubs() {
		addSubview(scrollView)
		scrollView.contentView.addSubview(mainStackView)
		scrollView.contentView.addSubview(vStackForButtons)
		[dateLabel, glucoseTitleLabel, glucoseTextfield, mealTitleLabel, mealTextfield, insulinTitleLabel, fastInsulinTextfield, longInsulinTextfield, notesTitleLabel, notesTextField].forEach { element in
			mainStackView.addArrangedSubview(element)
		}
		[saveButton, closeButton].forEach { button in
			button.heightAnchor.constraint(equalToConstant: 50)
				.isActive = true
			vStackForButtons.addArrangedSubview(button)
		}
		setupConstraintsForScrollView()
		setupConstraintsForTextFields()
		setupConstraintsForStackView()
		setupConstraintsForButtonsStack()
	}
	
	func setupConstraintsForScrollView() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.contentView.heightAnchor.constraint(equalToConstant: 2000)
			.isActive = true
		scrollView.topAnchor.constraint(equalTo: topAnchor)
			.isActive = true
		scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
			.isActive = true
		scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
			.isActive = true
		scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
			.isActive = true
	}
	
	func setupConstraintsForStackView() {
		mainStackView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor, constant: 50)
			.isActive = true
		mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor, constant: 16)
			.isActive = true
		mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor, constant: -16)
			.isActive = true
	}
	
	func setupConstraintsForButtonsStack() {
		vStackForButtons.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
			.isActive = true
		vStackForButtons.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
			.isActive = true
		vStackForButtons.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
			.isActive = true
	}
	
	func setupConstraintsForTextFields() {
		[glucoseTextfield, mealTextfield, fastInsulinTextfield, longInsulinTextfield, notesTextField].forEach { field in
			field.heightAnchor.constraint(equalToConstant: 50)
				.isActive = true
		}
	}
	
	//MARK: - Actions
	func setupBindings() {
		glucoseTextfield.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.glucoseTextFieldDidChanged($0))
			}
			.store(in: &cancellables)
		mealTextfield.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.mealTextFieldDidChanged($0))
			}
			.store(in: &cancellables)
		fastInsulinTextfield.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.fastInsulinTextFieldChanged($0))
			}
			.store(in: &cancellables)
		longInsulinTextfield.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.longInsulinTextFieldDidChanged($0))
			}
			.store(in: &cancellables)
		notesTextField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.noteTextViewDidChanged($0))
			}
			.store(in: &cancellables)
		saveButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.saveButtonPressed)
			}
			.store(in: &cancellables)
		closeButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.closeButtonPressed)
			}
			.store(in: &cancellables)
	}
}

//MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI
struct AddRecordScenePreview: PreviewProvider {
	static var previews: some View {
		ViewRepresentable(AddRecordSceneView())
	}
}
#endif

