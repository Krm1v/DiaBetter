//
//  AddRecordSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import UIKit
import Combine

final class AddRecordSceneViewController: BaseViewController<AddRecordSceneViewModel> {
	//MARK: - Properties
	private let contentView = AddRecordSceneView()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		bindActions()
		setupNavBar()
		contentView.setupDateLabel(with: viewModel.setupDataFormat())
	}
}

//MARK: - Private extension
private extension AddRecordSceneViewController {
	func setupNavBar() {
		navigationController?.navigationBar.prefersLargeTitles = true
		title = Localization.addNewRecord
	}
	
	func bindActions() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .glucoseTextFieldDidChanged(let text):
					viewModel.glucoseLvl = text.decimalValue
				case .mealTextFieldDidChanged(let text):
					viewModel.meal = text.decimalValue
				case .fastInsulinTextFieldChanged(let text):
					viewModel.fastInsulin = text.decimalValue
				case .longInsulinTextFieldDidChanged(let text):
					viewModel.longInsulin = text.decimalValue
				case .noteTextViewDidChanged(let text):
					viewModel.notes = text
				case .closeButtonPressed:
					viewModel.closeAddRecordScene()
				case .saveButtonPressed:
					viewModel.saveRecord()
				}
			}
			.store(in: &cancellables)
	}
}
