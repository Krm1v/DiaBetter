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
	private let scrollView = AxisScrollView()
	private lazy var emailTextField = buildSystemTextField(with: Localization.enterYourEmail,
														   keyBoardType: .emailAddress,
														   capitalization: .none)
	private lazy var passwordTextField = buildSystemTextField(with: Localization.enterYourPassword,
															  keyBoardType: .default,
															  capitalization: .none)
	private lazy var loginButton = buildGradientButton(with: Localization.login,
													   fontSize: Constants.basicButtonTitleFontSize)
	private lazy var titleLabel = buildTitleLabel(with: Constants.titleText)
	private lazy var loginLabel = buildFieldTitleLabel(with: Localization.email)
	private lazy var passwordLabel = buildFieldTitleLabel(with: Localization.password)
	private lazy var restorePasswordButton = buildSystemButton(with: Localization.restorePassword,
															   fontSize: Constants.basicButtonTitleFontSize)
	private lazy var createAccountButton = buildSystemButton(with: Localization.createAccount, fontSize: Constants.basicLabelFontSize)
	private lazy var vStackView = buildStackView(axis: .vertical,
												 alignment: .fill,
												 distribution: .fillProportionally,
												 spacing: Constants.basicStackViewSpacing)
	
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
		scrollView.delaysContentTouches = false
		setupLayout()
	}
	
	func setupLayout() {
		addSubview(scrollView, withEdgeInsets: .all(.zero), safeArea: true)
		scrollView.addSubview(titleLabel)
		scrollView.addSubview(vStackView)
		scrollView.addSubview(restorePasswordButton)
		scrollView.addSubview(loginButton)
		scrollView.addSubview(createAccountButton)
		[loginLabel, emailTextField, passwordLabel, passwordTextField].forEach { element in
			vStackView.addArrangedSubview(element)
		}
		setupConstraints()
		setupConstraintsForStackView()
	}
	
	func setupConstraints() {
		titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.basicTopSpacing)
			.isActive = true
		titleLabel.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor, constant: Constants.basicEdgeInsets)
			.isActive = true
		titleLabel.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor, constant: -Constants.basicEdgeInsets)
			.isActive = true
		createAccountButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.basicSpacing)
			.isActive = true
		createAccountButton.centerXAnchor.constraint(equalTo: centerXAnchor)
			.isActive = true
	}
	
	func setupConstraintsForStackView() {
		setupStackInternalContentConstraints()
		vStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.basicSpacing)
			.isActive = true
		vStackView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor, constant: Constants.basicEdgeInsets)
			.isActive = true
		vStackView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor, constant: -Constants.basicEdgeInsets)
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
		loginButton.topAnchor.constraint(equalTo: restorePasswordButton.bottomAnchor, constant: 50)
			.isActive = true
		loginButton.leadingAnchor.constraint(equalTo: vStackView.leadingAnchor)
			.isActive = true
		loginButton.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor)
			.isActive = true
		loginButton.heightAnchor.constraint(equalToConstant: Constants.basicHeight)
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
