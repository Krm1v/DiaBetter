//
//  ButtonsCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.04.2023.
//

import UIKit
import Combine

enum ButtonsCellActions {
	case saveButtonDidTapped
	case closeButtonDidTapped
}

final class ButtonsCell: BaseCollectionViewCell {
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<ButtonsCellActions, Never>()
	
	//MARK: - UI Elements
	private lazy var saveButton = buildGradientButton(with: Localization.save, fontSize: Constants.defaultButtonFontSize)
	private lazy var closeButton = buildBackButton(with: Localization.close)
	private lazy var vStackForButtons = buildStackView(axis: .vertical,
													   alignment: .fill,
													   distribution: .fillEqually,
													   spacing: Constants.defaultStackViewSpacing)
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupBindings()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupBindings()
	}
}

//MARK: - Private extension
private extension ButtonsCell {
	func setupUI() {
		backgroundColor = .clear
		setupLayout()
	}
	
	func setupLayout() {
		addSubview(vStackForButtons, constraints: [
			vStackForButtons.topAnchor.constraint(equalTo: topAnchor),
			vStackForButtons.leadingAnchor.constraint(equalTo: leadingAnchor),
			vStackForButtons.trailingAnchor.constraint(equalTo: trailingAnchor),
			vStackForButtons.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
		[saveButton, closeButton].forEach {
			vStackForButtons.addArrangedSubview($0)
		}
	}
	
	func setupBindings() {
		saveButton.tapPublisher
			.map { ButtonsCellActions.saveButtonDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
		
		closeButton.tapPublisher
			.map { ButtonsCellActions.closeButtonDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let defaultButtonFontSize: 	CGFloat = 13
	static let defaultStackViewSpacing: CGFloat = 16
}
