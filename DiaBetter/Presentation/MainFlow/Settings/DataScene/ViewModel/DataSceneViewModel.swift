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
	private let recordService: RecordsService
	private let userService: UserService
	private var records: [Record] = []
	@Published var sections: [SectionModel<DataSceneSections, DataSceneItems>] = []
	@Published var isConnected = false
	var inputURL: URL?
	
	//MARK: - Init
	init(recordService: RecordsService, userService: UserService) {
		self.recordService = recordService
		self.userService = userService
	}
	
	//MARK: - Overriden methods
	override func onViewWillAppear() {
		updateDatasource()
	}
	
	//MARK: - Public methods
	func openBackupScene() {
		transitionSubject.send(.moveToBackupScene)
	}
	
	func importBackup() {
		showFiles()
		loadRecords()
	}
}

//MARK: - Private extension
private extension DataSceneViewModel {
	func updateDatasource() {
		let appleHealthModel = AppleHealthCellModel(title: Localization.appleHealthConnect, isConnected: isConnected)
		let sectionFooterModel = DataSceneSectionsModel(title: Localization.appleHealthFooterDescription)
		let appleHealthSection = SectionModel<DataSceneSections, DataSceneItems>(
			section: .appleHealth(sectionFooterModel),
			items: [
				.appleHealthItem(appleHealthModel)
			]
		)
		
		let createBackupModel = BackupCellModel(title: Localization.createBackup, item: .backup)
		let createBackupSectionModel = DataSceneSectionsModel(title: nil)
		let createBackupSection = SectionModel<DataSceneSections, DataSceneItems>(
			section: .backup(createBackupSectionModel),
			items: [
				.backupItem(createBackupModel)
			]
		)
		
		let importModel = BackupCellModel(title: Localization.import, item: .ʼimportʼ)
		let importSectionModel = DataSceneSectionsModel(title: nil)
		let importSection = SectionModel<DataSceneSections, DataSceneItems>(
			section: .importSection(importSectionModel),
			items: [
				.importItem(importModel)
			]
		)
		
		sections = [appleHealthSection, createBackupSection, importSection]
	}
	
	func showFiles() {
		guard let inputURL = inputURL else {
			return
		}
		
		guard inputURL.startAccessingSecurityScopedResource() else { return }
			do {
				let inputData = try Data(contentsOf: inputURL)
				let decoder = JSONDecoder()
					self.records = try decoder.decode([Record].self, from: inputData)
			} catch let error {
				Logger.error(error.localizedDescription, shouldLogContext: true)
				return
		}
		inputURL.stopAccessingSecurityScopedResource()
	}
	
	func loadRecords() {
		guard let userId = userService.user?.remoteId else { return }
		if records.contains(where: { $0.userId != userId }) {
			let error = NSError(domain: Localization.wrongBackupErrorDescription, code: 1)
			errorSubject.send(error)
			return
		}
		
		recordService.uploadAllRecords(records: records)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					Logger.info("Finished", shouldLogContext: true)
				case .failure(let error):
					Logger.error(error.localizedDescription, shouldLogContext: true)
					self.errorSubject.send(error)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
}
