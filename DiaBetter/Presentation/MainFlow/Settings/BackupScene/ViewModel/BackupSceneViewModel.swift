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
	
	enum BackupActions: CaseIterable {
		case backup
		case share
	}
	
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<BackupSceneTransitions, Never>()
	private var records: [Record] = []
	private let userService: UserService
	private let recordService: RecordsService
	private var fileName = ""
	var outputURL: URL?
	var attachmentData: Data?
	var currentAction: BackupActions?
	
	//MARK: - @Published properties
	@Published var sections: [Section] = []
	@Published var startDate = Date()
	@Published var endDate = Date()
	
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
	func fetchRecordsSource(didFiltered: Bool) {
		didFiltered == true ? filterRecordsByDate() : fetchRecords()
	}
	
	func eraseAllData() {
		guard let userId = userService.user?.remoteId else {
			return
		}
		isLoadingSubject.send(true)
		recordService.deleteAllRecords(id: userId)
			.subscribe(on: DispatchQueue.global(qos: .background))
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					Logger.info("Finished", shouldLogContext: true)
					isLoadingSubject.send(false)
					infoSubject.send(("Done", "All data successfully deleted"))
				case .failure(let error):
					Logger.error(error.localizedDescription, shouldLogContext: true)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
}

//MARK: - Private extension
private extension BackupSceneViewModel {
	//MARK: - Datasource
	func updateDatasource() {
		let startDateModel = BackupDateCellModel(title: Localization.startDate,
												 date: startDate,
												 item: .startDate)
		
		let endDateModel = BackupDateCellModel(title: Localization.endDate,
											   date: endDate,
											   item: .endDate)
		
		let dateSectionModel = BackupSectionModel(title: Localization.pickDateRangeFooterText)
		
		let backupDateSection = Section(
			section: .backupDateSection(dateSectionModel),
			items: [
				.datePickerItem(startDateModel),
				.datePickerItem(endDateModel)
			])
		
		let backupModel = BackupShareCellModel(title: Localization.createBackup,
											   color: .regular,
											   item: .createBackup)
		
		let shareModel = BackupShareCellModel(title: Localization.shareData,
											  color: .regular,
											  item: .shareData)
		
		let shareSectionModel = BackupSectionModel(title: Localization.backupOrShareFooterText)
		let shareSection = Section(
			section: .shareSection(shareSectionModel),
			items: [
				.plainItem(backupModel),
				.plainItem(shareModel)
			])
		
		let deleteAllDataModel = BackupShareCellModel(title: Localization.eraseAllData,
													  color: .alert,
													  item: .eraseAllData)
		
		let deleteSectionModel = BackupSectionModel(title: Localization.eraseDataFooterText)
		let deleteAllDataSection = Section(
			section: .eraseDataSection(deleteSectionModel),
			items: [
				.plainItem(deleteAllDataModel)
			])
		
		sections = [backupDateSection, shareSection, deleteAllDataSection]
	}
	
	//MARK: - Network requests
	func fetchRecords() {
		guard let id = userService.user?.remoteId else { return }
		isLoadingSubject.send(true)
		recordService.fetchRecords(userId: id)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					guard let url = outputURL else { return }
					self.createBackupOrCSVFile(fileURL: url)
					Logger.info("Finished", shouldLogContext: true)
				case .failure(let error):
					self.isLoadingSubject.send(false)
					Logger.error(error.localizedDescription, shouldLogContext: true)
					self.errorSubject.send(error)
				}
			} receiveValue: { [weak self] records in
				guard let self = self else { return }
				self.records = records
				self.isLoadingSubject.send(false)
			}
			.store(in: &cancellables)
	}
	
	func filterRecordsByDate() {
		guard let id = userService.user?.remoteId else {
			return
		}
		isLoadingSubject.send(true)
		recordService.filterRecordsByDate(userId: id,
										  startDate: startDate,
										  endDate: endDate)
		.subscribe(on: DispatchQueue.global())
		.receive(on: DispatchQueue.main)
		.sink { [weak self] completion in
			guard let self = self else { return }
			switch completion {
			case .finished:
				guard let url = outputURL else { return }
				self.createBackupOrCSVFile(fileURL: url)
				Logger.info("Finished", shouldLogContext: true)
			case .failure(let error):
				self.isLoadingSubject.send(false)
				Logger.error(error.localizedDescription, shouldLogContext: true)
				errorSubject.send(error)
			}
		} receiveValue: { [weak self] records in
			guard let self = self else { return }
			self.records = records
			self.isLoadingSubject.send(false)
		}
		.store(in: &cancellables)
	}
	
	//MARK: - Create backup methods
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
	
	func createBackupFileIfNeeded(_ fileName: String) throws {
		guard let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
		let fileURL = filePath.appendingPathComponent(fileName).appendingPathExtension("json")
		if !FileManager.default.fileExists(atPath: fileURL.path) {
			let data = Data()
			try data.write(to: fileURL)
		}
	}
	
	//MARK: - Create .csv file for sharing data
	func buildRecordsDictionary() -> [[String: Any]] {
		var recordsResults: [[String: Any]] = []
		
		recordsResults = self.records.map { record in
			var recordsDictionary = [String: Any]()
			recordsDictionary.updateValue(record.recordDate.stringRepresentation(format: .dayMonthYearTime), forKey: "recordDate")
			recordsDictionary.updateValue(record.glucoseLevel?.convertToString() ?? "", forKey: "glucose")
			recordsDictionary.updateValue(record.fastInsulin?.convertToString() ?? "", forKey: "fastInsulin")
			recordsDictionary.updateValue(record.longInsulin?.convertToString() ?? "", forKey: "longInsulin")
			recordsDictionary.updateValue(record.meal?.convertToString() ?? "", forKey: "meal")
			recordsDictionary.updateValue(record.recordNote ?? "", forKey: "note")
			return recordsDictionary
		}
		return recordsResults
	}
	
	func createCSV() {
		let recordsDictionaries = buildRecordsDictionary()
		var csvString = "\("Date"), \("Glucose"), \("Fast insulin"), \("Long insulin"), \("Meal"), \("Note") \r\n\r\n\r\n\r\n\r\n"
		let _ = recordsDictionaries.map { dct in
			guard
				let dateString = dct["recordDate"],
				let glucose = dct["glucose"],
				let fastInsulin = dct["fastInsulin"],
				let longInsulin = dct["longInsulin"],
				let meal = dct["meal"],
				let note = dct["note"]
			else {
				return
			}
			csvString = csvString.appending("\(dateString) , \(glucose) , \(fastInsulin) , \(longInsulin) , \(meal) , \(note)\r\n")
		}
		
		let fileManager = FileManager.default
		do {
			let path = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			let fileURL = path.appendingPathComponent("Records", conformingTo: .commaSeparatedText)
			try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
			attachmentData = try Data(contentsOf: fileURL)
		} catch {
			debugPrint("Error happened")
		}
	}
	
	func createBackupOrCSVFile(fileURL: URL) {
		guard let currentAction = currentAction else {
			return
		}
		
		switch currentAction {
		case .backup:
			saveFile(fileURL)
		case .share:
			createCSV()
		}
	}
}


