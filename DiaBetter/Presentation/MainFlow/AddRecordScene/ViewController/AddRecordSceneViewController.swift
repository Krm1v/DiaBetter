//
//  AddRecordSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import UIKit
import Combine

final class AddRecordSceneViewController: BaseViewController<AddRecordSceneViewModel> {
	// MARK: - Properties
	private let contentView = AddNewRecordView()
	private let notification = NotificationCenter.default

	// MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		bindActions()
		addObservers()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateDiffableDatasourceSnapshot()
	}

	// MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		title = Localization.addNewRecord
	}

	// MARK: - Deinit
	deinit {
		removeObservers()
	}
}

// MARK: - Private extension
private extension AddRecordSceneViewController {
	func updateDiffableDatasourceSnapshot() {
		viewModel.$sections
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] sections in
				self.contentView.setupSnapshot(sections: sections)
			}
			.store(in: &cancellables)
	}

	func addObservers() {
		#warning("TODO: Change to publishers")
		notification.addObserver(
			self,
			selector: #selector(self.keyboardWillShow),
			name: .keyboardWillShow,
			object: nil)

		notification.addObserver(
			self,
			selector: #selector(self.keyboardWillHide),
			name: .keyboradWillHide,
			object: nil)
	}

	func removeObservers() {
		notification.removeObserver(
			self,
			name: .keyboardWillShow,
			object: nil)

		notification.removeObserver(
			self,
			name: .keyboradWillHide,
			object: nil)
	}

	@objc
	func keyboardWillShow(notification: NSNotification) {
		guard let userInfo = notification.userInfo else {
			return
		}
		guard let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
			return
		}
		let contentInsets = UIEdgeInsets(
			top: .zero,
			left: .zero,
			bottom: keyboardSize.height + keyboardSize.height / 1.5,
			right: .zero)
		contentView.changeScrollViewInsets(insets: contentInsets)
	}

	@objc
	func keyboardWillHide(notification: NSNotification) {
		let contentInsets = UIEdgeInsets.all(.zero)
		contentView.changeScrollViewInsets(insets: contentInsets)
	}

	func bindActions() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .hideKeyboardDidTapped:
					view.endEditing(true)

				case .saveButtonTapped:
					viewModel.saveRecord()

				case .closeButtonTapped:
					viewModel.closeAddRecordScene()

				case .noteTextViewDidChanged(let text):
					viewModel.note = text

				case .fastInsulinTextfieldDidChanged(let text):
					viewModel.fastInsulin = text.decimalValue

				case .basalInsulinTextfieldDidChanged(let text):
					viewModel.longInsulin = text.decimalValue

				case .glucoseOrMealTextfieldDidChanged(let text, let field):
					guard let field = field else {
						return
					}

					switch field.currentField {
					case .glucose:
						viewModel.glucoseLvl = text.decimalValue
						
					case .meal:
						viewModel.meal = text.decimalValue
					}

				case .dateDidChanged(let date):
					viewModel.date = date
				}
			}
			.store(in: &cancellables)
	}
}
