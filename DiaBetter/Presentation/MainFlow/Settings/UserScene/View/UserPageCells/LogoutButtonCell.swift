//
//  LogoutButtonCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 28.08.2023.
//

import UIKit
import Combine

enum LogoutButtonCellActions {
    case didTapped
}

final class LogoutButtonCell: BaseCollectionViewCell {
    // MARK: - UI Elements
    private lazy var logoutButton = buildSystemButton()
    
    // MARK: - Properties
    private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
    private let actionSubject = PassthroughSubject<LogoutButtonCellActions, Never>()
    
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
    func configure(_ model: UserProfileButtonModel) {
        logoutButton.setTitle(
            model.buttonTitle,
            for: .normal)
        bindActions()
    }
}

// MARK: - Private extension
private extension LogoutButtonCell {
    func setupUI() {
        addSubview(
            logoutButton,
            constraints: [
                logoutButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                logoutButton.heightAnchor.constraint(equalToConstant: Constants.defaultButtonHeight)
            ])
        
        logoutButton.setTitleColor(
            Colors.customPink.color,
            for: .normal)
    }
    
    func bindActions() {
        logoutButton.tapPublisher
            .map { LogoutButtonCellActions.didTapped }
            .subscribe(actionSubject)
            .store(in: &cancellables)
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultButtonHeight: CGFloat = 44
}
