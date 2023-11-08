//
//  NoteCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.04.2023.
//

import UIKit
import Combine

enum NoteCellActions {
	case textViewDidChanged(String)
}

final class NoteCell: BaseCollectionViewCell {
	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<NoteCellActions, Never>()

	// MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel()
	private lazy var noteTextView = NoteTextView()

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
	func configure(with model: NoteCellModel) {
		titleLabel.text = model.title
		setupBindings()
	}
}

// MARK: - Private extension
private extension NoteCell {
	func setupUI() {
		setupLayout()
		self.rounded(Constants.defaultCornerRadius)
		self.backgroundColor = Colors.darkNavyBlue.color
	}

	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: Constants.smallEdgeInset),

			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: Constants.largeEdgeInset)])

		addSubview(noteTextView, constraints: [
			noteTextView.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: Constants.smallEdgeInset),

			noteTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
			noteTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
			noteTextView.bottomAnchor.constraint(equalTo: bottomAnchor)])
	}

	func setupBindings() {
		noteTextView.textView.textPublisher
			.sink { [unowned self] text in
				guard let text = text else {
					return
				}
				actionSubject.send(.textViewDidChanged(text))
			}
			.store(in: &cancellables)
	}
}

// MARK: - Constants
private enum Constants {
	static let titleLabelFontSize:  CGFloat = 25
	static let defaultCornerRadius: CGFloat = 12
	static let smallEdgeInset: 		CGFloat = 8
	static let largeEdgeInset: 		CGFloat = 16
}
