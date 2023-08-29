//
//  UserNameTextField.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 29.08.2023.
//

import UIKit

final class UserNameTextField: UITextField {
	// MARK: - Properties
	private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
	
	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureTextField()
		self.delegate = self
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configureTextField()
		self.delegate = self
	}
}

// MARK: - Private extension
private extension UserNameTextField {
	func configureTextField() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.placeholder = Localization.user
		self.keyboardType = .default
		self.borderStyle = .none
		self.autocapitalizationType = .sentences
		self.contentMode = .right
	}
}

// MARK: - Extension UITextFieldDelegate
extension UserNameTextField: UITextFieldDelegate {
	func textField(
		_ textField: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {
		impactFeedbackGenerator.prepare()
		impactFeedbackGenerator.impactOccurred()
		let currentText = textField.text ?? ""
		
		guard let stringRange = Range(range, in: currentText) else {
			return false
		}
		
		let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
		
		if range.location == 0 && string == " " {
			return false
		}
		
		return updatedText.count <= 16
	}
}
