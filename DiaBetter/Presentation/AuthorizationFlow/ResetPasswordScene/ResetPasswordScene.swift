//
//  ResetPasswordScene.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 02.03.2023.
//

import UIKit
import Combine

enum ResetPasswordActions {
	case emailTextFieldChanged(String)
	case resetPasswordButtonTapped
	case backToLoginSceneButtonTapped
}

final class ResetPasswordSceneView: BaseView {
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<ResetPasswordActions, Never>()
	
	//MARK: - UIElements
	private lazy var resetPasswordButton = buildGradientButton(with: "Reset password", fontSize: Constants.basicFontSize)
	private lazy var backToLoginButton = buildBackButton(with: "Back to login")
	private lazy var emailTextField = buildSystemTextField(with: "Enter your email",
														   keyBoardType: .emailAddress,
														   capitalization: .none)
	private lazy var descriptionLabel = create(labelWith: Constants.descriptionLabelText, fontSize: Constants.basicFontSize)
	private lazy var vStackView = createStackView()
	
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
private extension ResetPasswordSceneView {
	func setupUI() {
		backgroundColor = .white
		addSubs()
		setupLayout()
	}
	
	func create(labelWith text: String, fontSize: CGFloat) -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = text
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = .zero
		label.font = FontFamily.Montserrat.semiBold.font(size: fontSize)
		label.minimumScaleFactor = Constants.baseMinimumScaleFactor
		return label
	}
	
	func createStackView() -> UIStackView {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.setup(axis: .vertical,
					alignment: .fill,
					distribution: .fillProportionally,
					spacing: Constants.basicStackViewSpacing)
		return stack
	}
	
	func addSubs() {
		addSubview(vStackView)
		[descriptionLabel, emailTextField, resetPasswordButton, backToLoginButton].forEach { element in
			vStackView.addArrangedSubview(element)
		}
	}
	
	func setupLayout() {
		resetPasswordButton.heightAnchor.constraint(equalToConstant: Constants.basicElementsHeight)
			.isActive = true
		backToLoginButton.heightAnchor.constraint(equalToConstant: Constants.basicElementsHeight)
			.isActive = true
		emailTextField.heightAnchor.constraint(equalToConstant: Constants.basicElementsHeight)
			.isActive = true
		vStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.basicTopEdgeInset)
			.isActive = true
		vStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.baseEdgeInsets)
			.isActive = true
		vStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.baseEdgeInsets)
			.isActive = true
		vStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
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
		resetPasswordButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.resetPasswordButtonTapped)
			}
			.store(in: &cancellables)
		backToLoginButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.backToLoginSceneButtonTapped)
			}
			.store(in: &cancellables)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let basicFontSize: CGFloat = 13
	static let baseEdgeInsets: CGFloat = 16
	static let baseMinimumScaleFactor: CGFloat = 0.5
	static let basicElementsHeight: CGFloat = 50
	static let basicTopEdgeInset: CGFloat = 50
	static let basicStackViewSpacing: CGFloat = 20
	static let descriptionLabelText = "Enter your email address which was used for registration and the new password will be send immediately."
}

//MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI
struct ResetPasswordScenePreview: PreviewProvider {
	static var previews: some View {
		ViewRepresentable(ResetPasswordSceneView())
	}
}
#endif
