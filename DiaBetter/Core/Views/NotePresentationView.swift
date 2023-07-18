//
//  NotePresentationView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.06.2023.
//

import UIKit
import Combine

enum NotePresentationViewActions {
	case textfieldDidChanged(String?)
}

final class NotePresentationView: UIView {
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<NotePresentationViewActions, Never>()
	private var cancellables = Set<AnyCancellable>()
	
	var isEditing: Bool = false {
		didSet { isEditing ? setupEditLayout() : setupShowLayout() }
	}
	
	var titleText: String? {
		get { titleLabel.text }
		set { titleLabel.text = newValue }
	}
	
	var valueText: String? {
		get { valueLabel.text }
		set { valueLabel.text = newValue }
	}
	
	//MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel(fontSize: Constants.defaultFontSize,
													   textAllignment: .natural)
	private lazy var valueLabel = buildUserInfoLabel()
	private(set) lazy var editTextView = NoteTextView()
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupShowLayout()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupShowLayout()
	}
	
	//MARK: - Public methods
	func setupShowLayout() {
		editTextView.isHidden = true
		valueLabel.isHidden.toggle()
	}
	
	func setupEditLayout() {
		valueLabel.isHidden = true
		editTextView.isHidden.toggle()
	}
	
	//MARK: - Deinit
	deinit {
		cancellables.removeAll()
	}
}

//MARK: - Private extension
private extension NotePresentationView {
	func setupUI() {
		self.rounded(Constants.defaultCornerRadius)
		self.backgroundColor = Colors.darkNavyBlue.color
		setupLayout()
		setupBindings()
	}
	
	func setupLayout() {
		addSubview(titleLabel, constraints: [
			titleLabel.topAnchor.constraint(equalTo: self.topAnchor,
											constant: Constants.defaultSmallEdgeInset),
			titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
												constant: Constants.defaultSmallEdgeInset)
		])
		
		addSubview(valueLabel, constraints: [
			valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
											constant: Constants.defaultSmallEdgeInset),
			valueLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,
												constant: Constants.defaultSmallEdgeInset),
			valueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
												 constant: -Constants.defaultLargeEdgeInset)
		])
		
		addSubview(editTextView, constraints: [
			editTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
											  constant: Constants.defaultSmallEdgeInset),
			editTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
												 constant: Constants.defaultSmallEdgeInset),
			editTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
												  constant: -Constants.defaultLargeEdgeInset),
			editTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
												 constant: -Constants.defaultLargeEdgeInset)
		])
	}
	
	func setupBindings() {
		editTextView.textView.textPublisher
			.replaceEmpty(with: nil)
			.map { NotePresentationViewActions.textfieldDidChanged($0) }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}

//MARK: - Extension UIElementsBuilder
extension NotePresentationView: UIElementsBuilder { }

//MARK: - Constants
fileprivate enum Constants {
	static let defaultFontSize: CGFloat = 17
	static let defaultCornerRadius: CGFloat = 12
	static let defaultSmallEdgeInset: CGFloat = 8
	static let defaultLargeEdgeInset: CGFloat = 16
}
