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
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<LoginSceneViewActions, Never>()
	
	//MARK: - UI Elements
	private lazy var emailTextField = buildSystemTextField(with: Localization.enterYourEmail,
														   keyBoardType: .emailAddress,
														   capitalization: .none)
	private lazy var passwordTextField = buildSystemTextField(with: Localization.enterYourPassword,
															  keyBoardType: .default,
															  capitalization: .none)
	private lazy var loginButton = buildGradientButton(with: Localization.login,
													   fontSize: Constants.basicButtonTitleFontSize)
	private lazy var titleLabel = buildTitleLabel(with: Constants.titleText)
	private lazy var emailLabel = buildFieldTitleLabel(with: Localization.email)
	private lazy var passwordLabel = buildFieldTitleLabel(with: Localization.password)
	private lazy var restorePasswordButton = buildSystemButton(with: Localization.restorePassword,
															   fontSize: Constants.basicButtonTitleFontSize)
	private lazy var createAccountButton = buildSystemButton(with: Localization.createAccount, fontSize: Constants.basicLabelFontSize)
	private lazy var vStackView = buildStackView(axis: .vertical,
												 alignment: .fill,
												 distribution: .fillProportionally,
												 spacing: Constants.basicStackViewSpacing)
	private lazy var substrateView = buildView(with: Colors.darkNavyBlue.color)
	lazy var videoContainer = buildView(with: .black)
	
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
private extension LoginSceneView {
	//MARK: - UI setting up
	func setupUI() {
		backgroundColor = .black
		setupLayout()
		substrateView.layer.cornerRadius = 20
		substrateView.alpha = 0.65
	}
	
	func setupLayout() {
		addSubview(videoContainer)
		addSubview(substrateView)
		addSubview(titleLabel)
		addSubview(restorePasswordButton)
		addSubview(loginButton)
		addSubview(createAccountButton)
		substrateView.addSubview(vStackView)
		[
			emailLabel,
			emailTextField,
			passwordLabel,
			passwordTextField
		].forEach { element in
			vStackView.addArrangedSubview(element)
		}
		setupConstraints()
		setupConstraintsForStackView()
		setupConstraintsForVideoContainer()
		setupConstraintsForSubstrateView()
	}
	
	//MARK: - Constraints methods
	func setupConstraints() {
		titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.basicTopSpacing)
			.isActive = true
		titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.basicEdgeInsets)
			.isActive = true
		titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.basicEdgeInsets)
			.isActive = true
		createAccountButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.basicSpacing)
			.isActive = true
		createAccountButton.centerXAnchor.constraint(equalTo: centerXAnchor)
			.isActive = true
	}
	
	func setupConstraintsForStackView() {
		setupStackInternalContentConstraints()
		vStackView.topAnchor.constraint(equalTo: substrateView.topAnchor, constant: 8)
			.isActive = true
		vStackView.leadingAnchor.constraint(equalTo: substrateView.leadingAnchor, constant: Constants.basicEdgeInsets)
			.isActive = true
		vStackView.trailingAnchor.constraint(equalTo: substrateView.trailingAnchor, constant: -Constants.basicEdgeInsets)
			.isActive = true
	}
	
	func setupStackInternalContentConstraints() {
		emailTextField.heightAnchor.constraint(equalToConstant: Constants.basicHeight)
			.isActive = true
		passwordTextField.heightAnchor.constraint(equalToConstant: Constants.basicHeight)
			.isActive = true
		restorePasswordButton.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor)
			.isActive = true
		restorePasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: Constants.restoreButtonSpacing)
			.isActive = true
		loginButton.topAnchor.constraint(equalTo: restorePasswordButton.bottomAnchor, constant: 30)
			.isActive = true
		loginButton.leadingAnchor.constraint(equalTo: vStackView.leadingAnchor)
			.isActive = true
		loginButton.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor)
			.isActive = true
		loginButton.heightAnchor.constraint(equalToConstant: Constants.basicHeight)
			.isActive = true
		loginButton.bottomAnchor.constraint(equalTo: substrateView.bottomAnchor, constant: -20)
			.isActive = true
	}
	
	func setupConstraintsForSubstrateView() {
		substrateView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.basicSpacing)
			.isActive = true
		substrateView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.basicEdgeInsets)
			.isActive = true
		substrateView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.basicEdgeInsets)
			.isActive = true
		substrateView.centerXAnchor.constraint(equalTo: centerXAnchor)
			.isActive = true
	}
	
	func setupConstraintsForVideoContainer() {
		videoContainer.topAnchor.constraint(equalTo: topAnchor)
			.isActive = true
		videoContainer.leadingAnchor.constraint(equalTo: leadingAnchor)
			.isActive = true
		videoContainer.trailingAnchor.constraint(equalTo: trailingAnchor)
			.isActive = true
		videoContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
			.isActive = true
		videoContainer.centerXAnchor.constraint(equalTo: centerXAnchor)
			.isActive = true
	}
	
	//MARK: - Action bindings
	func bindActions() {
		emailTextField.textPublisher
			.replaceNil(with: "")
			.sink { [unowned self] in
				actionSubject.send(.emailChanged($0)) }
			.store(in: &cancellables)
		passwordTextField.textPublisher
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

//MARK: - Constants
fileprivate enum Constants {
	static let titleText = "DiaBetter"
	static let labelsMinScaleFactor: CGFloat = 0.5
	static let basicButtonTitleFontSize: CGFloat = 13
	static let basicLabelFontSize: CGFloat = 17
	static let basicHeight: CGFloat = 50
	static let basicEdgeInsets: CGFloat = 16
	static let titleSize: CGFloat = 45
	static let basicStackViewSpacing: CGFloat = 8
	static let basicSpacing: CGFloat = 20
	static let restoreButtonSpacing: CGFloat = 25
	static let basicTopSpacing: CGFloat = 70
}

//MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI
struct LoginScenePreview: PreviewProvider {
	static var previews: some View {
		ViewRepresentable(LoginSceneView())
	}
}
#endif
