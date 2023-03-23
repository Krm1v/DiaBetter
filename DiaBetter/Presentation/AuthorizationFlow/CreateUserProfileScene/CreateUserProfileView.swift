//
//  CreateUserProfileView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.02.2023.
//

import UIKit
import Combine
import KeyboardLayoutGuide

enum CreateUserProfileActions {
	case emailTextFieldChanged(String)
	case passwordTextFieldChanged(String)
	case nameTextFieldChanged(String)
	case countryTextFieldChanged(String)
	case diabetesTypeTextFieldChanged(String)
	case fastActingInsulinTextFieldChanged(String)
	case basalInsulinTextFieldChanged(String)
	case createAccountTapped
	case backToLoginTapped
}

final class CreateUserProfileView: BaseView {
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<CreateUserProfileActions, Never>()
	
	//MARK: - UI Elements
	private let scrollView = AxisScrollView(axis: .vertical)
	private lazy var createAccountButton = buildGradientButton(with: Localization.createAccount,
															   fontSize: Constants.basicButtonTitleFontSize)
	private lazy var emailLabel = buildFieldTitleLabel(with: Localization.email)
	private lazy var passwordLabel = buildFieldTitleLabel(with: Localization.password)
	private lazy var nameLabel = buildFieldTitleLabel(with: Localization.name)
	private lazy var locationLabel = buildFieldTitleLabel(with: Localization.country)
	private lazy var diabetesTypeLabel = buildFieldTitleLabel(with: Localization.diabetsType)
	private lazy var fastActingInsulinTitleLabel = buildFieldTitleLabel(with: Localization.fastActingInsulin)
	private lazy var basalInsulinTitleLabel = buildFieldTitleLabel(with: Localization.basalInsulin)
	private lazy var emailTextField = buildSystemTextField(with: Localization.enterYourEmail,
														   keyBoardType: .emailAddress,
														   capitalization: .none)
	private lazy var passwordTextField = buildSystemTextField(with: Localization.enterYourPassword,
															  keyBoardType: .default, capitalization: .none)
	private lazy var nameTextField = buildSystemTextField(with: Localization.enterYourName,
														  keyBoardType: .default,
														  capitalization: .words)
	private lazy var locationTextField = buildSystemTextField(with: Localization.enterYourCountry,
															  keyBoardType: .default,
															  capitalization: .words)
	private lazy var diabetesTypeField = buildSystemTextField(with: Localization.diabetsType,
															  keyBoardType: .numberPad,
															  capitalization: .none)
	private lazy var fastActingInsulinField = buildSystemTextField(with: Localization.fastActingInsulin,
																   keyBoardType: .default,
																   capitalization: .words)
	private lazy var basalInsulinField = buildSystemTextField(with: Localization.basalInsulin,
															  keyBoardType: .default,
															  capitalization: .words)
	private lazy var backToLoginButton = buildBackButton(with: Localization.backToLogin)
	private lazy var mainStackView = buildStackView(spacing: Constants.basicStackViewSpacing)
	private lazy var buttonsStackView = buildStackView(distribution: .fillEqually,
													   spacing: Constants.basicStackViewSpacing)
	private lazy var buttonsUnderlyingView = buildView(with: .white)
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		bindActions()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		bindActions()
	}
}

//MARK: - Private extension
private extension CreateUserProfileView {
	//MARK: - UI setting up
	func setupUI() {
		backgroundColor = .white
		addSubs()
		scrollView.delaysContentTouches = false
		addGestureRecognizers()
	}
	
	func addSubs() {
		addSubview(scrollView)
		addSubview(buttonsUnderlyingView)
		scrollView.contentView.addSubview(mainStackView)
		buttonsUnderlyingView.addSubview(buttonsStackView)
		[emailLabel, emailTextField, passwordLabel, passwordTextField, nameLabel, nameTextField, locationLabel, locationTextField, diabetesTypeLabel, diabetesTypeField, fastActingInsulinTitleLabel, fastActingInsulinField, basalInsulinTitleLabel, basalInsulinField].forEach { element in
			mainStackView.addArrangedSubview(element)
		}
		[createAccountButton, backToLoginButton].forEach { button in
			buttonsStackView.addArrangedSubview(button)
		}
		setupLayout()
	}
	
	func addGestureRecognizers() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		addGestureRecognizer(tap)
	}
	
	//MARK: - Constraints
	func setupLayout() {
		setupConstraintsForScrollView()
		setupConstraintsForButtonsUnderlyingView()
		setupConstraintsForMainStack()
		setupConstraintsForTextFields()
		setupConstraintsForButtonsStack()
	}
	
	func setupConstraintsForMainStack() {
		mainStackView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor, constant: Constants.basicTopInset)
			.isActive = true
		mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor,
											   constant: Constants.basicEdgeInsets)
		.isActive = true
		mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor,
												constant: -Constants.basicEdgeInsets)
		.isActive = true
		mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor)
			.isActive = true
	}
	
	func setupConstraintsForButtonsUnderlyingView() {
		buttonsUnderlyingView.centerXAnchor.constraint(equalTo: centerXAnchor)
			.isActive = true
		buttonsUnderlyingView.leadingAnchor.constraint(equalTo: leadingAnchor)
			.isActive = true
		buttonsUnderlyingView.trailingAnchor.constraint(equalTo: trailingAnchor)
			.isActive = true
		buttonsUnderlyingView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
			.isActive = true
		buttonsUnderlyingView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.underlyingViewMultiplier)
			.isActive = true
	}
	
	func setupConstraintsForTextFields() {
		[emailTextField, passwordTextField, nameTextField, locationTextField, diabetesTypeField, fastActingInsulinField, basalInsulinField].forEach { field in
			field.heightAnchor.constraint(equalToConstant: Constants.basicHeight)
				.isActive = true
		}
	}
	
	func setupConstraintsForScrollView() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
			.isActive = true
		scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
			.isActive = true
		scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
			.isActive = true
		scrollView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
			.isActive = true
	}
	
	func setupConstraintsForButtonsStack() {
		[createAccountButton, backToLoginButton].forEach { button in
			button.heightAnchor.constraint(equalToConstant: Constants.basicHeight)
				.isActive = true
		}
		buttonsStackView.leadingAnchor.constraint(equalTo: buttonsUnderlyingView.leadingAnchor, constant: Constants.basicEdgeInsets)
			.isActive = true
		buttonsStackView.bottomAnchor.constraint(equalTo: buttonsUnderlyingView.bottomAnchor, constant: -Constants.basicInset)
			.isActive = true
		buttonsStackView.trailingAnchor.constraint(equalTo: buttonsUnderlyingView.trailingAnchor, constant: -Constants.basicEdgeInsets)
			.isActive = true
	}
	
	//MARK: - Actions
	func bindActions() {
		emailTextField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.emailTextFieldChanged($0))
			}
			.store(in: &cancellables)
		passwordTextField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.passwordTextFieldChanged($0))
			}
			.store(in: &cancellables)
		nameTextField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.nameTextFieldChanged($0))
			}
			.store(in: &cancellables)
		locationTextField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.countryTextFieldChanged($0))
			}
			.store(in: &cancellables)
		diabetesTypeField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.diabetesTypeTextFieldChanged($0))
			}
			.store(in: &cancellables)
		fastActingInsulinField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.fastActingInsulinTextFieldChanged($0))
			}
			.store(in: &cancellables)
		basalInsulinField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.basalInsulinTextFieldChanged($0))
			}
			.store(in: &cancellables)
		createAccountButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.createAccountTapped)
			}
			.store(in: &cancellables)
		backToLoginButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.backToLoginTapped)
			}
			.store(in: &cancellables)
	}
	
	@objc
	func hideKeyboard() {
		endEditing(true)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let basicButtonTitleFontSize: CGFloat = 13
	static let basicStackViewSpacing: CGFloat = 8
	static let underlyingViewMultiplier: CGFloat = 0.16
	static let basicEdgeInsets: CGFloat = 16
	static let basicHeight: CGFloat = 50
	static let basicInset: CGFloat = 20
	static let basicTopInset: CGFloat = 30
}

#if DEBUG
import SwiftUI
struct CreateUserProfilePreview: PreviewProvider {
	static var previews: some View {
		ViewRepresentable(CreateUserProfileView())
	}
}
#endif
