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
						debugPrint("All data backup")
					case .createBackup:
						debugPrint("Create backup")
					case .shareData:
						debugPrint("Share data")
					case .eraseAllData:
						debugPrint("Erase data")
					}
				}
			}
			.store(in: &cancellables)
	}
}
