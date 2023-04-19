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
	private let contentView = AddNewRecordView()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		bindActions()
		//		contentView.setupDateLabel(with: viewModel.setupDataFormat())
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupNavBar()
		updateDiffableDatasourceSnapshot()
	}
}

//MARK: - Private extension
private extension AddRecordSceneViewController {
	func setupNavBar() {
		title = Localization.addNewRecord
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.largeTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: Colors.customPink.color,
			NSAttributedString.Key.font: FontFamily.Montserrat.bold.font(size: 30)
		]
		navigationController?.navigationBar.backgroundColor = .black
		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: Colors.customPink.color
		]
		UINavigationBar.appearance().tintColor = Colors.customPink.color
	}
	
	func updateDiffableDatasourceSnapshot() {
		viewModel.$sections
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] sections in
				self.contentView.setupSnapshot(sections: sections)
			}
			.store(in: &cancellables)
	}
	
	func bindActions() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .saveButtonTapped:
					viewModel.addNewRecord()
				case .closeButtonTapped:
					viewModel.closeAddRecordScene()
				}
			}
			.store(in: &cancellables)
	}
}
