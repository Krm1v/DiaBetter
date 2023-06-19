//
//  DiaryDetailSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.06.2023.
//

import UIKit
import Combine

enum DiaryDetailSceneViewActions {
	case editButtonDidTapped
	case saveButtonDidTapped
	case cancelButtonDidTapped
	case deleteButtonDidTapped
	case glucoseTextfieldDidChanged(String)
	case mealTextfieldDidChanged(String)
	case fastInsulinTextfieldDidChanged(String)
	case basalInsulinTextfieldDidChanged(String)
	case hideKeyboardDidTapped
	case datePickerDidChanged(Date)
	case noteDidChanged(String)
}

final class DiaryDetailSceneView: BaseView {
	//MARK: - UI Elements
	private lazy var axisScrollView = AxisScrollView(axis: .vertical)
	private lazy var vStack = buildStackView(axis: .vertical,
											 alignment: .fill,
											 distribution: .fill,
											 spacing: Constants.stackViewMaxSpacing)
	private lazy var viewStack = buildStackView(axis: .vertical,
												alignment: .fill,
												distribution: .fill,
												spacing: Constants.stackViewMinSpacing)
	private lazy var buttonsStack = buildStackView(axis: .vertical,
												   alignment: .fill,
												   distribution: .fillEqually,
												   spacing: Constants.stackViewMinSpacing)
	private lazy var glucoseView = RecordPresentationView()
	private lazy var mealView = RecordPresentationView()
	private lazy var fastInsulinView = RecordPresentationView()
	private lazy var basalInsulinView = RecordPresentationView()
	private lazy var saveButton = buildGradientButton(with: Localization.save,
													  fontSize: Constants.defaultButtonFontSize)
	private lazy var cancelButton = buildBackButton(with: Localization.cancel)
	private lazy var deleteButton = buildDeleteButton()
	private lazy var editButton = buildNavBarButton()
	private lazy var noteView = NotePresentationView()
	private lazy var datePicker = UIDatePicker()
	private lazy var hideKeyboardTap = UITapGestureRecognizer()
	
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<DiaryDetailSceneViewActions, Never>()
	
	//MARK: - Colors
	private let firstColorSet = [UIColor.red.cgColor, Colors.customPink.color.cgColor]
	private let secondColorSet = [Colors.customPink.color.cgColor, Colors.customRed.color.cgColor]
	private let thirdColorSet = [Colors.customPink.color.cgColor, UIColor.red.cgColor]
	private var colorSet: [[CGColor]] = []
	private var colorIndex = 0
	
	//MARK: - Public properties
	var isEditing: Bool = false {
		didSet { isEditing == true ? presentEditState() : presentShowState()  }
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
	
	//MARK: - Public methods
	func configure(_ model: DiaryDetailModel) {
		glucoseView.titleText = Localization.glucose
		mealView.titleText = Localization.meal
		fastInsulinView.titleText = Localization.fastActingInsulin
		basalInsulinView.titleText = Localization.basalInsulin
		noteView.titleText = Localization.notes
		datePicker.date = model.date
		glucoseView.valueText = model.glucose
		mealView.valueText = model.meal
		fastInsulinView.valueText = model.fastInsulin
		basalInsulinView.valueText = model.longInsulin
		noteView.valueText = model.note
	}
	
	func setupEditButton(for controller: UIViewController) {
		editButton.style = .plain
		editButton.image = UIImage(systemName: "square.and.pencil")
		controller.navigationItem.rightBarButtonItem = editButton
	}
	
	func presentShowState() {
		makeFadeAnimation(buttonsStack, .zero)
		[
			glucoseView,
			mealView,
			fastInsulinView,
			basalInsulinView
		].forEach { $0.isEditing = false }
		noteView.isEditing = false
		editButton.isEnabled = true
		datePicker.isEnabled = false
	}
	
	func presentEditState() {
		makeFadeAnimation(buttonsStack, Constants.fullOpacity)
		[
			glucoseView,
			mealView,
			fastInsulinView,
			basalInsulinView
		].forEach { $0.isEditing = true }
		noteView.isEditing = true
		editButton.isEnabled = false
		datePicker.isEnabled = true
	}
	
	func animateDeleteButton(_ animation: CABasicAnimation) {
		colorSet.append(firstColorSet)
		colorSet.append(secondColorSet)
		colorSet.append(thirdColorSet)
		deleteButton.gradientLayer.colors = colorSet[colorIndex]
		updateColorIndex()
		deleteButton.gradientLayer.setColors(
			animation: animation,
			colorSet[colorIndex],
			animated: true,
			duration: Constants.deleteButtonAnimationDuration,
			timingFuncName: .linear)
	}
}

//MARK: - Private extension
private extension DiaryDetailSceneView {
	func setupUI() {
		backgroundColor = .black
		setupBindings()
		setupLayout()
		axisScrollView.delaysContentTouches = false
		buttonsStack.alpha = .zero
		datePicker.maximumDate = .now
		datePicker.datePickerMode = .dateAndTime
		datePicker.tintColor = Colors.customPink.color
	}
	
	func setupLayout() {
		addGestureRecognizer(hideKeyboardTap)
		let contentRect: CGRect = axisScrollView.subviews.reduce(into: .zero) { rect, view in
			rect = rect.union(view.frame)
		}
		axisScrollView.contentSize = contentRect.size
		addSubview(axisScrollView, withEdgeInsets: .all(.zero))
		axisScrollView.contentView.addSubview(vStack, constraints: [
			vStack.topAnchor.constraint(equalTo: axisScrollView.contentView.topAnchor),
			vStack.leadingAnchor.constraint(equalTo: axisScrollView.contentView.leadingAnchor,
											constant: Constants.defaultEdgeInset),
			vStack.trailingAnchor.constraint(equalTo: axisScrollView.contentView.trailingAnchor,
											 constant: -Constants.defaultEdgeInset),
			vStack.centerXAnchor.constraint(equalTo: axisScrollView.contentView.centerXAnchor),
			vStack.bottomAnchor.constraint(equalTo: axisScrollView.contentView.bottomAnchor,
										   constant: -20)
		])
		
		[viewStack, buttonsStack].forEach { vStack.addArrangedSubview($0) }
		[datePicker, glucoseView, mealView, fastInsulinView, basalInsulinView].forEach {
			$0.heightAnchor.constraint(equalToConstant: 50).isActive = true
			viewStack.addArrangedSubview($0) }
		noteView.heightAnchor.constraint(equalToConstant: 160).isActive = true
		viewStack.addArrangedSubview(noteView)
		[saveButton, cancelButton, deleteButton].forEach {
			$0.heightAnchor.constraint(equalToConstant: 50).isActive = true
			buttonsStack.addArrangedSubview($0) }
	}
	
	func makeFadeAnimation(_ view: UIView, _ alpha: CGFloat) {
		UIView.animate(withDuration: 0.3,
					   delay: .zero,
					   options: .curveLinear) {
			view.alpha = alpha
		}
	}
	
	func updateColorIndex() {
		if colorIndex < colorSet.count - 1 {
			colorIndex += 1
		} else {
			colorIndex = 0
		}
	}
	
	func setupBindings() {
		editButton.tapPublisher
			.map { DiaryDetailSceneViewActions.editButtonDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
		
		saveButton.tapPublisher
			.map { DiaryDetailSceneViewActions.saveButtonDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
		
		cancelButton.tapPublisher
			.map { DiaryDetailSceneViewActions.cancelButtonDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
		
		deleteButton.tapPublisher
			.map { DiaryDetailSceneViewActions.deleteButtonDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
		
		hideKeyboardTap.tapPublisher
			.map { _ in DiaryDetailSceneViewActions.hideKeyboardDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
		
		glucoseView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .textfieldDidChanged(let text):
					actionSubject.send(.glucoseTextfieldDidChanged(text ?? ""))
				}
			}
			.store(in: &cancellables)
		
		mealView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .textfieldDidChanged(let text):
					actionSubject.send(.mealTextfieldDidChanged(text ?? ""))
				}
			}
			.store(in: &cancellables)
		
		fastInsulinView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .textfieldDidChanged(let text):
					actionSubject.send(.fastInsulinTextfieldDidChanged(text ?? ""))
				}
			}
			.store(in: &cancellables)
		
		basalInsulinView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .textfieldDidChanged(let text):
					actionSubject.send(.basalInsulinTextfieldDidChanged(text ?? ""))
				}
			}
			.store(in: &cancellables)
		
		datePicker.datePublisher
			.map { DiaryDetailSceneViewActions.datePickerDidChanged($0) }
			.subscribe(actionSubject)
			.store(in: &cancellables)
		
		noteView.editTextView.textView.textPublisher
			.map { DiaryDetailSceneViewActions.noteDidChanged($0 ?? "") }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let defaultEdgeInset: CGFloat = 16
	static let stackViewMinSpacing: CGFloat = 8
	static let stackViewMaxSpacing: CGFloat = 20
	static let defaultButtonFontSize: CGFloat = 13
	static let fullOpacity: CGFloat = 1.0
	static let deleteButtonAnimationDuration: TimeInterval = 1
}
