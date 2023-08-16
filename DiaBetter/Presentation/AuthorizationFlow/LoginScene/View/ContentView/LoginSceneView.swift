//
//  LoginSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 24.02.2023.
//

import UIKit
import Combine
import KeyboardLayoutGuide

enum LoginSceneViewActions {
	case emailChanged(String)
	case passwordChanged(String)
	case loginTapped
	case restorePasswordTapped
	case createAccountTapped
}

final class LoginSceneView: BaseView {
	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<LoginSceneViewActions, Never>()

	// MARK: - UI Elements
	private lazy var emailTextField = buildSystemTextField(with: Localization.enterYourEmail,
														   keyBoardType: .emailAddress,
														   capitalization: .none)
	private lazy var passwordTextField = PasswordTextField()
	private lazy var loginButton = buildGradientButton(with: Localization.login,
													   fontSize: Constants.basicButtonTitleFontSize)
	private lazy var titleLabel = buildTitleLabel(with: Constants.titleText)
	private lazy var emailLabel = buildFieldTitleLabel(with: Localization.email)
	private lazy var passwordLabel = buildFieldTitleLabel(with: Localization.password)
	private lazy var restorePasswordButton = buildSystemButton(with: Localization.restorePassword,
															   fontSize: Constants.basicButtonTitleFontSize)
	private lazy var createAccountButton = buildSystemButton(with: Localization.createAccount,
															 fontSize: Constants.basicLabelFontSize)
	private lazy var vStackView = buildStackView(axis: .vertical,
												 alignment: .fill,
												 distribution: .fillEqually,
												 spacing: Constants.basicStackViewSpacing)
	private lazy var substrateView = buildView(with: Colors.darkNavyBlue.color)
	lazy var videoContainer = buildView(with: .black)

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
private extension LoginSceneView {
	// MARK: - UI and layout setup
	func setupUI() {
		backgroundColor = .black
		setupLayout()
		substrateView.layer.cornerRadius = Constants.substrateViewCornerRadius
		substrateView.alpha = Constants.substrateViewAlpha
	}

	func setupLayout() {
		addSubview(videoContainer, constraints: [
			videoContainer.topAnchor.constraint(equalTo: topAnchor),
			videoContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
			videoContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
			videoContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
			videoContainer.centerXAnchor.constraint(equalTo: centerXAnchor)
		])

		addSubview(titleLabel, constraints: [
			titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
											constant: Constants.basicTopSpacing),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
												constant: Constants.basicEdgeInsets),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
												 constant: -Constants.basicEdgeInsets)
		])

		addSubview(substrateView, constraints: [
			substrateView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
											   constant: Constants.basicSpacing),
			substrateView.leadingAnchor.constraint(equalTo: leadingAnchor,
												   constant: Constants.basicEdgeInsets),
			substrateView.trailingAnchor.constraint(equalTo: trailingAnchor,
													constant: -Constants.basicEdgeInsets),
			substrateView.centerXAnchor.constraint(equalTo: centerXAnchor)
		])

		substrateView.addSubview(vStackView, constraints: [
			vStackView.topAnchor.constraint(equalTo: substrateView.topAnchor,
											constant: Constants.vStackViewTopAnchor),
			vStackView.leadingAnchor.constraint(equalTo: substrateView.leadingAnchor,
												constant: Constants.basicEdgeInsets),
			vStackView.trailingAnchor.constraint(equalTo: substrateView.trailingAnchor,
												 constant: -Constants.basicEdgeInsets)
		])

		[
			emailLabel,
			emailTextField,
			passwordLabel,
			passwordTextField
		].forEach { element in
			vStackView.addArrangedSubview(element)
		}
		[emailTextField, passwordTextField].forEach {
			$0.heightAnchor.constraint(equalToConstant: Constants.basicHeight).isActive = true
		}

		addSubview(restorePasswordButton, constraints: [
			restorePasswordButton.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor),
			restorePasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor,
													   constant: Constants.restoreButtonSpacing)
		])

		addSubview(loginButton, constraints: [
			loginButton.topAnchor.constraint(equalTo: restorePasswordButton.bottomAnchor,
											 constant: Constants.loginButtonTopAnchor),
			loginButton.leadingAnchor.constraint(equalTo: vStackView.leadingAnchor),
			loginButton.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor),
			loginButton.heightAnchor.constraint(equalToConstant: Constants.basicHeight),
			loginButton.bottomAnchor.constraint(equalTo: substrateView.bottomAnchor,
												constant: -Constants.basicSpacing)
		])

		addSubview(createAccountButton, constraints: [
			createAccountButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
														constant: -Constants.basicSpacing),
			createAccountButton.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}

	// MARK: - Action bindings
	func bindActions() {
		emailTextField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.emailChanged($0)) }
			.store(in: &cancellables)

		passwordTextField.textField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.passwordChanged($0)) }
			.store(in: &cancellables)

		loginButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.loginTapped)
			}
			.store(in: &cancellables)

		restorePasswordButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.restorePasswordTapped)
			}
			.store(in: &cancellables)

		createAccountButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.createAccountTapped)
			}
			.store(in: &cancellables)
	}
}

// MARK: - Constants
private enum Constants {
	static let titleText = Localization.appTitle
	static let labelsMinScaleFactor: CGFloat = 0.5
	static let basicButtonTitleFontSize: CGFloat = 13
	static let basicLabelFontSize: CGFloat = 17
	static let basicHeight: CGFloat = 50
	static let basicEdgeInsets: CGFloat = 16
	static let titleSize: CGFloat = 45
	static let basicStackViewSpacing: CGFloat = .zero
	static let basicSpacing: CGFloat = 20
	static let restoreButtonSpacing: CGFloat = 25
	static let basicTopSpacing: CGFloat = 70
	static let substrateViewCornerRadius: CGFloat = 20
	static let substrateViewAlpha: CGFloat = 0.65
	static let vStackViewTopAnchor: CGFloat = 8
	static let loginButtonTopAnchor: CGFloat = 30
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI
struct LoginScenePreview: PreviewProvider {
	static var previews: some View {
		ViewRepresentable(LoginSceneView())
	}
}
#endif
