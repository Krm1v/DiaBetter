//
//  ResetPasswordSceneView.swift
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
    // MARK: - Properties
    private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
    private let actionSubject = PassthroughSubject<ResetPasswordActions, Never>()
    
    // MARK: - UIElements
    private lazy var resetPasswordButton = buildSystemButton(with: Localization.restorePassword)
    
    private lazy var backToLoginButton = buildSystemButton(
        with: Localization.backToLogin,
        fontSize: Constants.largeFontSize)
    
    private lazy var emailTextField = buildSystemTextField(
        with: Localization.enterYourEmail,
        keyBoardType: .emailAddress,
        capitalization: .none)
    
    private lazy var descriptionLabel = buildUserInfoLabel(
        with: Localization.resetPasswordDescription)
    
    private lazy var vStackView = buildStackView(
        axis: .vertical,
        alignment: .fill,
        distribution: .fillProportionally,
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
private extension ResetPasswordSceneView {
    func setupUI() {
        backgroundColor = .black
        addSubs()
        descriptionLabel.textColor = .white
        descriptionLabel.minimumScaleFactor = Constants.baseMinimumScaleFactor
        descriptionLabel.font = FontFamily.Montserrat.semiBold.font(
            size: Constants.basicFontSize)
        descriptionLabel.numberOfLines = .zero
        descriptionLabel.textAlignment = .center
        resetPasswordButton.setTitleColor(
            Colors.customPink.color,
            for: .normal)
    }
    
    func addSubs() {
        addSubview(
            vStackView,
            constraints: [
                vStackView.topAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.topAnchor,
                    constant: Constants.basicTopEdgeInset),
                
                vStackView.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: Constants.baseEdgeInsets),
                
                vStackView.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -Constants.baseEdgeInsets),
                
                vStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        
        [
            descriptionLabel,
            emailTextField,
            resetPasswordButton,
            backToLoginButton
        ].forEach { vStackView.addArrangedSubview($0) }
        
        [
            resetPasswordButton,
            backToLoginButton,
            emailTextField
        ].forEach { $0.heightAnchor.constraint(equalToConstant: Constants.basicElementsHeight).isActive = true }
    }
    
    // MARK: - Actions
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

// MARK: - Constants
private enum Constants {
    static let basicFontSize: 		   CGFloat = 13
    static let baseEdgeInsets: 		   CGFloat = 16
    static let baseMinimumScaleFactor: CGFloat = 0.5
    static let basicElementsHeight:    CGFloat = 44
    static let basicTopEdgeInset: 	   CGFloat = 50
    static let basicStackViewSpacing:  CGFloat = 16
    static let largeFontSize:          CGFloat = 17
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI
struct ResetPasswordScenePreview: PreviewProvider {
    static var previews: some View {
        ViewRepresentable(ResetPasswordSceneView())
    }
}
#endif
