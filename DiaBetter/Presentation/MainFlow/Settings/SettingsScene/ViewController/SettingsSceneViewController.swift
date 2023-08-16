//
//  SettingsSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.03.2023.
//

import UIKit
import Combine
import MessageUI

final class SettingsSceneViewController: BaseViewController<SettingsSceneViewModel> {
	// MARK: - Properties
	private let contentView = SettingsSceneView()

	// MARK: - UIView lifecycle
	override func loadView() {
		view = contentView
	}

	override func viewDidLoad() {
		setupActions()
		super.viewDidLoad()
	}

	// MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		title = Localization.settings
	}
}

// MARK: - Private extension
private extension SettingsSceneViewController {
	func setupActions() {
		contentView.actionPublisher
			.sink { [unowned self] actions in
				switch actions {
				case .cellTapped(let setting):
					switch setting {
					case .user: 		 viewModel.openDetailSettingsScreen(.user)
					case .notifications: viewModel.openDetailSettingsScreen(.notifications)
					case .data:			 viewModel.openDetailSettingsScreen(.data)
					case .units: 		 viewModel.openDetailSettingsScreen(.units)
					case .credits: 		 viewModel.openDetailSettingsScreen(.credits)
					case .sendFeedback:  sendEmail()
					default: break
					}
				}
			}
			.store(in: &cancellables)
	}

	func sendEmail() {
		let recipientEmail = "hellodiabetter@gmail.com"
		let subject = Localization.sendFeedback
		if MFMailComposeViewController.canSendMail() {
			let mail = MFMailComposeViewController()
			mail.mailComposeDelegate = self
			mail.setToRecipients([recipientEmail])
			mail.setSubject(subject)
			present(mail, animated: true)
		} else if let emailURL = createEmailUrl(to: recipientEmail, subject: subject) {
			UIApplication.shared.open(emailURL)
		}
	}
}

// MARK: - Extension MFMailComposeViewControllerDelegate
extension SettingsSceneViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(
		_ controller: MFMailComposeViewController,
		didFinishWith result: MFMailComposeResult,
		error: Error?
	) {
		controller.dismiss(animated: true)
	}
}
