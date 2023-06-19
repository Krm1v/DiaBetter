//
//  DiaryDetailSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.06.2023.
//

import UIKit

final class DiaryDetailSceneViewController: BaseViewController<DiaryDetailSceneViewModel> {
	//MARK: - Properties
	private let contentView = DiaryDetailSceneView()
	private let animation = CABasicAnimation()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		bindActions()
		animation.delegate = self
		contentView.configure(viewModel.setupDatasource())
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		contentView.isEditing = false
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.animateDeleteButton(animation)
	}
	
	//MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		title = Localization.detail
		navigationItem.largeTitleDisplayMode = .never
		contentView.setupEditButton(for: self)
	}
}

//MARK: - Private extension
private extension DiaryDetailSceneViewController {
	func bindActions() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .editButtonDidTapped:
					contentView.isEditing = true
					
				case .saveButtonDidTapped:
					viewModel.updateRecord()
					
				case .cancelButtonDidTapped:
					contentView.isEditing = false
					
				case .deleteButtonDidTapped:
					presentDeleteRecordAlert()
					
				case .glucoseTextfieldDidChanged(let text):
					viewModel.glucose = text.decimalValue
					
				case .mealTextfieldDidChanged(let text):
					viewModel.meal = text.decimalValue
					
				case .fastInsulinTextfieldDidChanged(let text):
					viewModel.fastInsulin = text.decimalValue
					
				case .basalInsulinTextfieldDidChanged(let text):
					viewModel.longInsulin = text.decimalValue
					
				case .hideKeyboardDidTapped:
					view.endEditing(true)
					
				case .datePickerDidChanged(let date):
					viewModel.date = date
					
				case .noteDidChanged(let text):
					viewModel.note = text
				}
			}
			.store(in: &cancellables)
	}
	
	func presentDeleteRecordAlert() {
		let alert = UIAlertController(title: "Are you sure you want to delete this record?",
									  message: "This operation can't be aborted.",
									  preferredStyle: .alert)
		let deleteAction = UIAlertAction(title: Localization.delete, style: .destructive) { [weak self] _ in
			guard let self = self else { return }
			self.viewModel.deleteRecord()
		}
		let cancelAction = UIAlertAction(title: Localization.cancel, style: .cancel)
		alert.addAction(deleteAction); alert.addAction(cancelAction)
		present(alert, animated: true)
	}
}

//MARK: - Extension CAAnimationDelegate
extension DiaryDetailSceneViewController: CAAnimationDelegate {
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if flag {
			contentView.animateDeleteButton(animation)
		}
	}
}
