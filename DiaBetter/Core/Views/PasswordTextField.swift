//
//  PasswordTextField.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.05.2023.
//

import UIKit

final class PasswordTextField: UIView {
	// MARK: - UI Elements
	private(set) lazy var textField: UITextField = {
		let textField = UITextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.placeholder = Localization.enterYourPassword
		textField.keyboardType = .default
		textField.borderStyle = .roundedRect
		textField.backgroundColor = Colors.darkNavyBlue.color
		textField.autocapitalizationType = .sentences
		return textField
	}()

	private(set) lazy var trailingButton: UIButton = {
		let button = UIButton(type: .custom,
							  primaryAction: UIAction { [unowned self] _ in self.toggle() })
		button.tintColor = Colors.customDarkenPink.color
		return button
	}()

	// MARK: - Properties
	var securityMode: Bool = true { didSet { setupTextField() } }
	var text: String? {
		get { textField.text }
		set { textField.text = newValue }
	}

	private var isPasswordVisible = false

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayout()
		setupTextField()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupLayout()
		setupTextField()
	}
}

// MARK: - Private extension
private extension PasswordTextField {
	func setupTextField() {
		if securityMode {
			trailingButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
			trailingButton.frame.size = CGSize(width: 30, height: 20)
			textField.rightViewMode = .always
			let viewContainer = UIView(frame: CGRect(origin: .zero,
													 size: CGSize(width: 40, height: 20)))
			viewContainer.addSubview(trailingButton)
			textField.rightView = viewContainer
			textField.isSecureTextEntry = true
		}
	}

	func setupLayout() {
		addSubview(textField, withEdgeInsets: .all(.zero))
	}

	func toggle() {
		textField.isSecureTextEntry.toggle()
		if textField.isSecureTextEntry {
			trailingButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
		} else {
			trailingButton.setImage(UIImage(systemName: "eye"), for: .normal)
		}
	}
}
