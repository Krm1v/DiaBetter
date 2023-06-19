//
//  NoteTextView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.04.2023.
//

import UIKit
import Combine

final class NoteTextView: UIView {
	//MARK: - UIElements
	private(set) lazy var textView: UITextView = {
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isScrollEnabled = false
		textView.font = FontFamily.Montserrat.regular.font(size: Constants.basicFontSize)
		textView.textAlignment = .left
		textView.textColor = .white
		textView.backgroundColor = Colors.darkNavyBlue.color
		return textView
	}()
	
	private(set) lazy var charactersCountLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = FontFamily.Montserrat.regular.font(size: Constants.basicFontSize)
		label.textColor = .systemGray
		label.text = Constants.maxCharacters.description
		return label
	}()
	
	private(set) var fakePlaceholder: UILabel = {
		let label = UILabel()
		label.text = Localization.howDoYouFeel
		label.font = FontFamily.Montserrat.regular.font(size: Constants.basicFontSize)
		label.textColor = .tertiaryLabel
		label.sizeToFit()
		return label
	}()
	
	//MARK: - Properties
	var text: String? {
		get { textView.text }
		set { textView.text = newValue }
	}
	
	var isActive = false
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
}

//MARK: - Private extension
private extension NoteTextView {
	func setupUI() {
		addSubs()
		setupLayout()
		textView.delegate = self
	}
	
	func addSubs() {
		addSubview(textView, constraints: [
			textView.topAnchor.constraint(equalTo: topAnchor),
			textView.leadingAnchor.constraint(equalTo: leadingAnchor),
			textView.trailingAnchor.constraint(equalTo: trailingAnchor),
			textView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
		[fakePlaceholder, charactersCountLabel].forEach { textView.addSubview($0) }
	}
	
	func setupLayout() {
		guard let pointSize = textView.font?.pointSize else {
			return
		}
		fakePlaceholder.frame.origin = CGPoint(x: 15, y: (pointSize) / 1.4)
		charactersCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
													   constant: -Constants.basicEdgeInset)
			.isActive = true
		charactersCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
													 constant: -Constants.basicEdgeInset)
			.isActive = true
		textView.textContainerInset = Constants.textContainerInsets
	}
}

//MARK: - Extension UITextViewDelegate
extension NoteTextView: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		fakePlaceholder.isHidden = !textView.text.isEmpty
		charactersCountLabel.text = "\(Constants.maxCharacters - textView.text.count)"
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		guard let charCount = textView.text?.count else { return false }
		return charCount < Constants.maxCharacters || text == ""
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let basicFontSize: CGFloat = 13
	static let maxCharacters = 120
	static let textContainerInsets = UIEdgeInsets(top: 9, left: 9, bottom: 0, right: 0)
	static let basicEdgeInset: CGFloat = 16
}
