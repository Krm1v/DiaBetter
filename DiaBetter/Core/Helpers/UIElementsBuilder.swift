//
//  UIElementsBuilder.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 02.03.2023.
//

import UIKit

protocol UIElementsBuilder {}

// MARK: - Extension UIElementBuilder
extension UIElementsBuilder {
	// MARK: - Views
	func buildView(with color: UIColor = .clear) -> UIView {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = color
		return view
	}

	// MARK: - Buttons
	func buildGradientButton(with text: String, fontSize: CGFloat) -> GradientedButton {
		let button = GradientedButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle(text, for: .normal)
		button.setTitleColor(Colors.customPink.color, for: .normal)
		button.titleLabel?.font = FontFamily.Montserrat.semiBold.font(size: fontSize)
		return button
	}

	func buildBackButton(with title: String) -> UIButton {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle(title, for: .normal)
		button.setTitleColor(Colors.customDarkenPink.color, for: .normal)
		button.layer.cornerRadius = Constants.basicCornerRadius
		button.layer.borderWidth = Constants.basicBorderWidth
		button.layer.borderColor = Colors.customDarkenPink.color.cgColor
		button.titleLabel?.font = FontFamily.Montserrat.semiBold.font(size: Constants.basicButtonTitleFontSize)
		return button
	}

	func buildSystemButton(with title: String, fontSize: CGFloat) -> UIButton {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle(title, for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .clear
		button.titleLabel?.font = FontFamily.Montserrat.semiBold.font(size: fontSize)
		return button
	}

	func buildDeleteButton() -> GradientFilledButton {
		let button = GradientFilledButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle(Localization.delete, for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = FontFamily.Montserrat.semiBold.font(size: 13)
		return button
	}

	func buildNavBarButton() -> UIBarButtonItem {
		let button = UIBarButtonItem()
		return button
	}

	// MARK: - TextFields
	func buildSystemTextField(
		with placeholder: String = "",
		keyBoardType: UIKeyboardType = .default,
		capitalization: UITextAutocapitalizationType = .words
	) -> UITextField {
		let textField = UITextField()
		textField.placeholder = placeholder
		textField.keyboardType = keyBoardType
		textField.borderStyle = .roundedRect
		textField.backgroundColor = Colors.darkNavyBlue.color
		textField.autocapitalizationType = capitalization
		return textField
	}

	// MARK: - Labels
	func buildFieldTitleLabel(
		with text: String = "",
		fontSize: CGFloat = Constants.basicLabelFontSize,
		textAllignment: NSTextAlignment = .natural
	) -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .white
		label.font = FontFamily.Montserrat.regular.font(size: fontSize)
		label.text = text + ":"
		label.textAlignment = textAllignment
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = Constants.labelTextMinScaleFactor
		return label
	}

	func buildUserInfoLabel(with text: String = "") -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .systemGray
		label.font = FontFamily.Montserrat.semiBold.font(size: Constants.basicLabelFontSize)
		label.text = text
		label.textAlignment = .natural
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = Constants.labelTextMinScaleFactor
		return label
	}

	func buildTitleLabel(
		with text: String = "",
		fontSize: CGFloat = Constants.basicTitleFontSize
	) -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Colors.customPink.color
		label.font = FontFamily.Montserrat.bold.font(size: fontSize)
		label.text = text
		label.textAlignment = .center
		label.minimumScaleFactor = Constants.labelTextMinScaleFactor
		return label
	}

	// MARK: - StackViews
	func buildStackView(
		axis: NSLayoutConstraint.Axis = .vertical,
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill,
		spacing: CGFloat = .zero
	) -> UIStackView {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.setup(axis: axis,
					alignment: alignment,
					distribution: distribution,
					spacing: spacing)
		return stack
	}
}

// MARK: - Constants
private enum Constants {
	static let basicButtonTitleFontSize: CGFloat = 13
	static let basicLabelFontSize: CGFloat = 15
	static let labelTextMinScaleFactor: CGFloat = 0.5
	static let basicTitleFontSize: CGFloat = 45
	static let basicCornerRadius: CGFloat = 7
	static let basicBorderWidth: CGFloat = 1
}
