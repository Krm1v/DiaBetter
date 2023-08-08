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
					case .endDate:
						viewModel.endDate = date
					}
					
				case .plainCellDidTapped(let items):
					switch items.item {
					case .backupAllData:
						viewModel.backupData(didFiltered: false)
						presentDocumentPickerController()
						
					case .createBackup:
						presentActionSheet("Backup data in date range",
										   "Backup all data") { [weak self] didFiltered in
							guard let self = self else { return }
							self.viewModel.backupData(didFiltered: didFiltered)
							self.presentDocumentPickerController()
						}
						
					case .shareData:
						presentActionSheet("Share data in date range",
										   "Share all data") { [weak self] didFiltered in
							guard let self = self else { return }
							self.viewModel.shareRecords(didFiltered: didFiltered)
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
		let recipientEmail = "hellodiabetter@gmail.com"
		let subject = "Send feedback"
		if MFMailComposeViewController.canSendMail() {
			let mail = MFMailComposeViewController()
			mail.mailComposeDelegate = self
			mail.setToRecipients([recipientEmail])
			mail.setSubject(subject)
			guard let data = viewModel.attachmentData else { return }
			mail.addAttachmentData(data, mimeType: "text/csv", fileName: "Record.csv")
			present(mail, animated: true)
		} else if let emailURL = createEmailUrl(to: recipientEmail, subject: subject) {
			UIApplication.shared.open(emailURL)
		}
	}
}

//MARK: - Extension UIDocumentPickerDelegate
extension BackupSceneViewController: UIDocumentPickerDelegate { }

//MARK: - Extension MFMailComposeViewControllerDelegate
extension BackupSceneViewController: MFMailComposeViewControllerDelegate { }
