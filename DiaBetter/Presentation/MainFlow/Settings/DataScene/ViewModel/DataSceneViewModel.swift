//
//  DataSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.07.2023.
//

import Foundation
import Combine

final class DataSceneViewModel: BaseViewModel {
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<DataSceneTransitions, Never>()
	@Published var sections: [SectionModel<DataSceneSections, DataSceneItems>] = []
	@Published var isConnected = false
	
	//MARK: - Overriden methods
	override func onViewWillAppear() {
		updateDatasource()
	}
	
	//MARK: - Public methods
	func openBackupScene() {
		transitionSubject.send(.moveToBackupScene)
	}
}

//MARK: - Private extension
private extension DataSceneViewModel {
	func updateDatasource() {
		let appleHealthModel = AppleHealthCellModel(title: "Apple Health connect", isConnected: isConnected)
		let sectionFooterModel = AppleHealthSectionModel(title: "Turn on to let DiaBetter connect with Apple Health to write and read data")
		let appleHealthSection = SectionModel<DataSceneSections, DataSceneItems>(
			section: .appleHealth(sectionFooterModel),
			items: [
				.appleHealthItem(appleHealthModel)
			]
		)
		
		let createBackupModel = BackupCellModel(title: "Create backup", item: .backup)
		let createBackupSection = SectionModel<DataSceneSections, DataSceneItems>(
			section: .backup,
			items: [
				.backupItem(createBackupModel)
			]
		)
		
		sections = [appleHealthSection, createBackupSection]
	}
}
