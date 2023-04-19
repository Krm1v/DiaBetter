//
//  NoteCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.04.2023.
//

import UIKit
import Combine
import KeyboardLayoutGuide

final class NoteCell: UICollectionViewCell {
	//MARK: - Properties
	var model: GlucoseLevelOrMealCellModel?
	
	//MARK: - UI Elements
	private lazy var titleLabel = buildTitleLabel(fontSize: 25)
	private lazy var noteTextView = NoteTextView()
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
	
	func configure(with model: NoteCellModel) {
		titleLabel.text = model.title
	}
}

//MARK: - Private extension
private extension NoteCell {
	func setupUI() {
		backgroundColor = Colors.darkNavyBlue.color
		self.rounded(12)
		setupLayout()
	}
	
	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
		])
		addSubview(noteTextView, constraints: [
			noteTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			noteTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
			noteTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
			noteTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
}

//MARK: - Extension SelfConfiguringCell
extension NoteCell: SelfConfiguringCell {
	static var reuseID: String {
		"noteCell"
	}
}

//MARK: - Extension UIElementsBuilder
extension NoteCell: UIElementsBuilder {}

