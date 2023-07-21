//
//  BackupSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 18.07.2023.
//

import Foundation
import Combine

final class BackupSceneViewModel: BaseViewModel {
	typealias Section = SectionModel<BackupSceneSections, BackupSceneItems>
	
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<BackupSceneTransitions, Never>()
	@Published var sections: [SectionModel<BackupSceneSections, BackupSceneItems>] = []
	@Published var startDate = Date()
	@Published var endDate = Date()
	@Published var backupRecords = [Data]()
	private var records: [Record] = []
	private let userService: UserService
	private let recordService: RecordsService
	private var fileName = ""
	var outputURL: URL?
	
	//MARK: - Init
	init(recordService: RecordsService, userService: UserService) {
		self.recordService = recordService
		self.userService = userService
	}
	
	//MARK: - Overriden methods
	override func onViewDidLoad() {
		setupFileURL()
	}
	
	override func onViewWillAppear() {
		updateDatasource()
	}
	
	//MARK: - Public methods
	func backupData() {
		createBackup()
	}
}

//MARK: - Private extension
private extension BackupSceneViewModel {
	func updateDatasource() {
		let startDateModel = BackupDateCellModel(title: Localization.startDate,
												 date: startDate,
												 item: .startDate)
		let endDateModel = BackupDateCellModel(title: Localization.endDate,
											   date: endDate,
											   item: .endDate)
		let allDataBackupModel = BackupShareCellModel(title: Localization.backupAllData,
													  color: .largeTitle,
													  item: .backupAllData)
		let dateSectionModel = BackupSectionModel(title: Localization.pickDateRangeFooterText)
		let backupDateSection = Section(section: .backupDateSection(dateSectionModel), items: [
			.datePickerItem(startDateModel),
			.datePickerItem(endDateModel),
			.plainItem(allDataBackupModel)
		])
		
		let backupModel = BackupShareCellModel(title: Localization.createBackup,
											   color: .regular,
											   item: .createBackup)
		let shareModel = BackupShareCellModel(title: Localization.shareData,
											  color: .regular,
											  item: .shareData)
		let shareSectionModel = BackupSectionModel(title: Localization.backupOrShareFooterText)
		let shareSection = Section(section: .shareSection(shareSectionModel), items: [
			.plainItem(backupModel),
			.plainItem(shareModel)
		])
		
		let deleteAllDataModel = BackupShareCellModel(title: Localization.eraseAllData,
													  color: .alert,
													  item: .eraseAllData)
		let deleteSectionModel = BackupSectionModel(title: Localization.eraseDataFooterText)
		let deleteAllDataSection = Section(section: .eraseDataSection(deleteSectionModel), items: [
			.plainItem(deleteAllDataModel)
		])
		
		sections = [backupDateSection, shareSection, deleteAllDataSection]
	}
	
	func createBackup() {
		fetchRecords()
	}
	
	func saveFile(_ url: URL) {
		do {
			let jsonEncoder = JSONEncoder()
			let jsonCodedData = try jsonEncoder.encode(records)
			guard let prettyJSON = jsonCodedData.prettyPrintedJSONString else { return }
			try prettyJSON.write(to: url, atomically: true, encoding: String.Encoding.utf8.rawValue)
		} catch let error {
			Logger.error(error.localizedDescription, shouldLogContext: true)
			return
		}
	}
	
	func setupFileURL() {
		guard let docDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		else { return }
		let fileNameDate = Date().stringRepresentation(format: .dayMonthYear)
		fileName = "DiaBetter-\(fileNameDate)"
		let outputURL = docDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("json")
		self.outputURL = outputURL
		do {
			try createBackupFileIfNeeded(fileName)
		} catch let error {
			Logger.error(error.localizedDescription, shouldLogContext: true)
		}
	}
	
//	func showFiles(_ file: Data) {
//		let fileManager = FileManager.default
//		
//		guard let docDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
//		else { return }
//		
//		let inputFileURL = docDirectoryURL.appendingPathComponent(fileName)
//		
//		guard fileManager.fileExists(atPath: inputFileURL.path)
//		else {
//			return
//		}
//		
//		do {
//			let inputData = try Data(contentsOf: inputFileURL)
//			let decoder = JSONDecoder()
//			let decodedString = try decoder.decode(Data.self, from: inputData)
//		} catch let error {
//			Logger.error(error.localizedDescription, shouldLogContext: true)
//			return
//		}
//	}
	
	func fetchRecords() {
		guard let id = userService.user?.remoteId else { return }
		isLoadingSubject.send(true)
		recordService.fetchRecords(userId: id)
			.receive(on: DispatchQueue.global(qos: .userInitiated))
			.sink { [weak self] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					guard let url = outputURL else { return }
					self.saveFile(url)
					Logger.info("Finished", shouldLogContext: true)
				case .failure(let error):
					Logger.error(error.localizedDescription, shouldLogContext: true)
					self.errorSubject.send(error)
				}
			} receiveValue: { [weak self] records in
				guard let self = self else { return }
				self.records = records
				DispatchQueue.main.async {
					self.isLoadingSubject.send(false)
				}
			}
			.store(in: &cancellables)
	}
	
	func createBackupFileIfNeeded(_ fileName: String) throws {
		guard let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
		let fileURL = filePath.appendingPathComponent(fileName).appendingPathExtension("json")
		if !FileManager.default.fileExists(atPath: fileURL.path) {
			let data = Data()
			try data.write(to: fileURL)
		}
	}
}

