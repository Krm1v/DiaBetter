//
//  BackupSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.07.2023.
//

import UIKit
import Combine

final class BackupSceneViewController: BaseViewController<BackupSceneViewModel> {
	//MARK: - Properties
	private let contentView = BackupSceneView()
	
	//MARK: - UI View lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupBindings()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupDatasourceSnapshot()
	}
	
	//MARK: - Overriden methods
	override func setupNavBar() {
		title = "Backup"
		navigationItem.largeTitleDisplayMode = .always
	}
}

//MARK: - Private extension
private extension BackupSceneViewController {
	func setupDatasourceSnapshot() {
		viewModel.$sections
			.sink { [unowned self] sections in
				contentView.setupSnapshot(sections: sections)
			}
			.store(in: &cancellables)
	}
	
	func setupBindings() {
		contentView.actionPublisher
			.sink { [unowned self] actions in
				switch actions {
				case .dateCellDidTapped(let date, let items):
					switch items.item {
					case .startDate:
						viewModel.startDate = date
						debugPrint(date)
					case .endDate:
						viewModel.endDate = date
						debugPrint(date)
					}
					
				case .plainCellDidTapped(let items):
					switch items.item {
					case .backupAllData:
						viewModel.backupData(didFiltered: false)
						presentDocumentPickerController()
					case .createBackup:
						viewModel.backupData(didFiltered: true)
						presentDocumentPickerController()
					case .shareData:
						debugPrint("Share data")
					case .eraseAllData:
						showDeleteAllAlert()
					}
				}
			}
			.store(in: &cancellables)
	}
	
	func showDeleteAllAlert() {
		let alert = UIAlertController(title: "Are you sure you want to delete all your data?",
									  message: "This action can't be undo.",
									  preferredStyle: .alert)
		let deleteAction = UIAlertAction(title: Localization.delete, style: .destructive) { [weak self] _ in
			guard let self = self else { return }
			self.viewModel.eraseAllData()
		}
		let cancelAction = UIAlertAction(title: Localization.cancel, style: .cancel)
		alert.addAction(deleteAction); alert.addAction(cancelAction)
		present(alert, animated: true)
	}
	
	func presentDocumentPickerController() {
		guard let url = viewModel.outputURL else { return }
		let uiDocumentController = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
		uiDocumentController.delegate = self
		present(uiDocumentController, animated: true, completion: nil)
	}
}

//MARK: - Extension UIDocumentPickerDelegate
extension BackupSceneViewController: UIDocumentPickerDelegate { }
