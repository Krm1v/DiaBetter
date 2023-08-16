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
	case createAccountTapped
	case backToLoginTapped
}

final class CreateUserProfileView: BaseView {
	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<CreateUserProfileActions, Never>()

	// MARK: - UI Elements
	private let scrollView = AxisScrollView(axis: .vertical)
	private lazy var createAccountButton = buildGradientButton(with: Localization.createAccount,
															   fontSize: Constants.basicButtonTitleFontSize)
	private lazy var emailLabel = buildFieldTitleLabel(with: Localization.email)
	private lazy var passwordLabel = buildFieldTitleLabel(with: Localization.password)
	private lazy var descriptionLabel = buildUserInfoLabel(with: Localization.passwordDescription)
	private lazy var emailTextField = buildSystemTextField(with: Localization.enterYourEmail,
														   keyBoardType: .emailAddress,
														   capitalization: .none)
	private lazy var passwordTextField = PasswordTextField()
	private lazy var backToLoginButton = buildBackButton(with: Localization.backToLogin)
	private lazy var mainStackView = buildStackView(spacing: Constants.basicStackViewSpacing)
	private lazy var buttonsStackView = buildStackView(distribution: .fillEqually,
													   spacing: Constants.basicStackViewSpacing)
	// MARK: - Init
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

// MARK: - Private extension
private extension CreateUserProfileView {
	// MARK: - UI setting up
	func setupUI() {
		backgroundColor = .black
		setupLayout()
		addGestureRecognizers()
		scrollView.delaysContentTouches = false
		descriptionLabel.textColor = .white
		descriptionLabel.numberOfLines = .zero
		descriptionLabel.textAlignment = .center
		descriptionLabel.minimumScaleFactor = Constants.minScaleFactor
		descriptionLabel.font = FontFamily.Montserrat.regular.font(size: Constants.descriptionLabelFontSize)
	}

	func setupLayout() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(scrollView, constraints: [
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		scrollView.contentView.addSubview(mainStackView, constraints: [
			mainStackView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor,
											   constant: Constants.basicTopInset),
			mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor,
												   constant: Constants.basicEdgeInsets),
			mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor,
													constant: -Constants.basicEdgeInsets),
			mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor)
		])

		[emailTextField, passwordTextField].forEach {
			$0.heightAnchor.constraint(equalToConstant: Constants.basicHeight)
			.isActive = true }
		[createAccountButton, backToLoginButton].forEach {
			$0.heightAnchor.constraint(equalToConstant: Constants.basicHeight)
				.isActive = true
		}

		scrollView.addSubview(buttonsStackView, constraints: [
			buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor,
													  constant: Constants.basicEdgeInsets),
			buttonsStackView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor,
													 constant: -Constants.basicInset),
			buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
													   constant: -Constants.basicEdgeInsets)
		])

		[
			emailLabel,
			emailTextField,
			passwordLabel,
			passwordTextField,
			descriptionLabel
		].forEach {
			mainStackView.addArrangedSubview($0)
		}

		[createAccountButton, backToLoginButton].forEach {
			buttonsStackView.addArrangedSubview($0)
		}
		scrollView.bringSubviewToFront(buttonsStackView)
	}

	func addGestureRecognizers() {
		#warning("TODO: Change for Publisher")
		let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		addGestureRecognizer(tap)
	}

	// MARK: - Actions
	func bindActions() {
		emailTextField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.emailTextFieldChanged($0))
			}
			.store(in: &cancellables)

		passwordTextField.textField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.passwordTextFieldChanged($0))
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

	// MARK: - Objc methods
	@objc
	func hideKeyboard() {
		endEditing(true)
	}
}

// MARK: - Constants
private enum Constants {
	static let basicButtonTitleFontSize: CGFloat = 13
	static let basicStackViewSpacing: 	 CGFloat = 8
	static let underlyingViewMultiplier: CGFloat = 0.2
	static let basicEdgeInsets: 		 CGFloat = 16
	static let basicHeight: 			 CGFloat = 50
	static let basicInset: 				 CGFloat = 20
	static let basicTopInset: 			 CGFloat = 50
	static let minScaleFactor: 			 CGFloat = 0.5
	static let descriptionLabelFontSize: CGFloat = 13
}

#if DEBUG
import SwiftUI
struct CreateUserProfilePreview: PreviewProvider {
	static var previews: some View {
		ViewRepresentable(CreateUserProfileView())
	}
}
#endif
