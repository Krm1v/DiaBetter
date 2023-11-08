//
//  NotificationsSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import UIKit
import Combine

final class NotificationsSceneViewController: BaseViewController<NotificationsSceneViewModel> {
	// MARK: - Properties
	private let contentView = NotificationsSceneView()

	// MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupBindings()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateDiffableDatasourceSnapshot()
	}

	// MARK: - Overriden methods
	override func setupNavBar() {
		title = Localization.notifications
		navigationItem.largeTitleDisplayMode = .always
		contentView.setupSaveButton(for: self)
	}
}

// MARK: - Private extension
private extension NotificationsSceneViewController {
	func updateDiffableDatasourceSnapshot() {

		viewModel.$sections
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] sections in
				self.contentView.setupSnapshot(sections: sections)
			}
			.store(in: &cancellables)
	}

	func setupBindings() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .notificationsEnablerDidToggled(let isOn):
					viewModel.didChangedNotificationState(isOn: isOn) { [weak self] in
						guard let self = self else {
							return
						}
						self.showAccessDeniedAlert()
					}

				case .reminderSwitchDidToggled(let type, let isOn):
					viewModel.didChangedState(for: type, isOn: isOn)

				case .reminderTimeDidChanged(let type, let time, let dayTime):
					viewModel.didChangedTime(
						for: type,
						time: time,
						dayTime: dayTime)

				case .saveButtonDidTapped:
					viewModel.setReminders()
				}
			}
			.store(in: &cancellables)
	}

	func showAccessDeniedAlert() {
		let alertController = UIAlertController(
			title: Localization.accessDenied,
			message: Localization.notificationAccessDeniedMessage,
			preferredStyle: .alert)

		let goToSettingsAction = UIAlertAction(
			title: Localization.goToSettings,
			style: .default) { _ in
				UIApplication.shared.openSettings()
			}
		let cancelAction = UIAlertAction(
			title: Localization.cancel,
			style: .cancel) { [weak self] _ in
				guard let self = self else {
					return
				}
				self.viewModel.disableNotificationSwitch()
			}
		alertController.addAction(goToSettingsAction)
		alertController.addAction(cancelAction)
		present(alertController, animated: true)
	}
}
