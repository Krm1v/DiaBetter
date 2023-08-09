//
//  BackupSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.07.2023.
//

import UIKit
import Combine
import MessageUI

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
		title = Localization.backup
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
					case .endDate:
						viewModel.endDate = date
					}
					
				case .plainCellDidTapped(let items):
					switch items.item {
					case .createBackup:
						presentActionSheet(Localization.backupDataInRange,
										   Localization.backupAllData) { [weak self] didFiltered in
							guard let self = self else { return }
							self.viewModel.currentAction = .backup
							self.viewModel.fetchRecordsSource(didFiltered: didFiltered)
							self.presentDocumentPickerController()
						}
						
					case .shareData:
						presentActionSheet(Localization.shareDataInRange,
										   Localization.shareAllData) { [weak self] didFiltered in
							guard let self = self else { return }
							self.viewModel.currentAction = .share
							self.viewModel.fetchRecordsSource(didFiltered: didFiltered)
							sendEmail()
						}
						
					case .eraseAllData:
						showDeleteAllAlert()
					}
				}
			}
			.store(in: &cancellables)
	}
	
	func showDeleteAllAlert() {
		let alert = UIAlertController(title: Localization.deletionAllDataWarning,
									  message: Localization.deletionAllDataDescription,
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
	
	func presentActionSheet(_ firstActionTitle: String, _ secondActionTitle: String, _ completion: @escaping (Bool) -> (Void)) {
		let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let firstAction = UIAlertAction(title: firstActionTitle, style: .default) { _ in
			completion(true)
		}
		let secondAction = UIAlertAction(title: secondActionTitle, style: .default) { _ in
			completion(false)
		}
		let cancelAction = UIAlertAction(title: Localization.cancel, style: .cancel)
		actionSheetController.addAction(firstAction); actionSheetController.addAction(secondAction)
		actionSheetController.addAction(cancelAction)
		present(actionSheetController, animated: true)
	}
	
	func sendEmail() {
		let subject = Localization.recordsEmailSubject
		if MFMailComposeViewController.canSendMail() {
			let mail = MFMailComposeViewController()
			mail.mailComposeDelegate = self
			mail.setSubject(subject)
			guard let data = viewModel.attachmentData else { return }
			mail.addAttachmentData(data, mimeType: "text/csv", fileName: "Record.csv")
			present(mail, animated: true)
		} else if let emailURL = createEmailUrl(to: "", subject: subject) {
			UIApplication.shared.open(emailURL)
		}
	}
}

//MARK: - Extension UIDocumentPickerDelegate
extension BackupSceneViewController: UIDocumentPickerDelegate { }

//MARK: - Extension MFMailComposeViewControllerDelegate
extension BackupSceneViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}
}
