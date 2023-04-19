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
		textView.isScrollEnabled = true
		textView.font = FontFamily.Montserrat.regular.font(size: 13)
		textView.textAlignment = .left
		textView.textColor = .white
		textView.backgroundColor = Colors.darkNavyBlue.color
		return textView
	}()
	
	private(set) lazy var charactersCountLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = FontFamily.Montserrat.regular.font(size: 13)
		label.textColor = .systemGray
		label.text = "250"
		return label
	}()
	
	private(set) var fakePlaceholder: UILabel = {
		let label = UILabel()
		label.text = "Record your feelings"
		label.font = FontFamily.Montserrat.regular.font(size: 13)
		label.textColor = .tertiaryLabel
		label.sizeToFit()
		return label
	}()
	
	//MARK: - Properties
	var text: String? {
		get { textView.text }
		set { textView.text = newValue }
	}
	
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
		charactersCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
			.isActive = true
		charactersCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
			.isActive = true
		textView.textContainerInset = UIEdgeInsets(top: 9, left: 9, bottom: 0, right: 0)
	}
}
