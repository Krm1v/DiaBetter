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

	// MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<BackupSceneTransitions, Never>()
	private var records: [Record] = []
	private let userService: UserService
	private let recordService: RecordsService
	private let fileManager = FileManager.default
	private var fileName = ""

	var currentAction: BackupActions?

	// MARK: - @Published properties
	@Published var sections: [Section] = []
	@Published var startDate = Date()
	@Published var endDate = Date()
	@Published var attachmentURL: URL?
	@Published var outputURL: URL?

	// MARK: - Init
	init(recordService: RecordsService, userService: UserService) {
		self.recordService = recordService
		self.userService = userService
	}

	// MARK: - Overriden methods
	override func onViewWillAppear() {
		updateDatasource()
	}

	// MARK: - Public methods
	func fetchRecordsSource(didFiltered: Bool) {
		didFiltered ? filterRecordsByDate() : fetchRecords()
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
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					Logger.info("Finished")
					self.isLoadingSubject.send(false)
					infoSubject.send((Localization.done, Localization.dataDeletedMessage))
				case .failure(let error):
					isLoadingSubject.send(false)
					Logger.error(error.localizedDescription)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
}

// MARK: - Private extension
private extension BackupSceneViewModel {
	// MARK: - Datasource
	func updateDatasource() {
		let startDateModel = BackupDateCellModel(
			title: Localization.startDate,
			date: startDate,
			item: .startDate)

		let endDateModel = BackupDateCellModel(
			title: Localization.endDate,
			date: endDate,
			item: .endDate)

		let dateSectionModel = BackupSectionModel(
			title: Localization.pickDateRangeFooterText)

		let backupDateSection = Section(
			section: .backupDateSection(dateSectionModel),
			items: [
				.datePickerItem(startDateModel),
				.datePickerItem(endDateModel)])

		let backupModel = BackupShareCellModel(
			title: Localization.createBackup,
			color: .regular,
			item: .createBackup)

		let shareModel = BackupShareCellModel(
			title: Localization.shareData,
			color: .regular,
			item: .shareData)

		let shareSectionModel = BackupSectionModel(
			title: Localization.backupOrShareFooterText)

		let shareSection = Section(
			section: .shareSection(shareSectionModel),
			items: [
				.plainItem(backupModel),
				.plainItem(shareModel)])

		let deleteAllDataModel = BackupShareCellModel(
			title: Localization.eraseAllData,
			color: .alert,
			item: .eraseAllData)

		let deleteSectionModel = BackupSectionModel(
			title: Localization.eraseDataFooterText)

		let deleteAllDataSection = Section(
			section: .eraseDataSection(deleteSectionModel),
			items: [
				.plainItem(deleteAllDataModel)])

		sections = [backupDateSection, shareSection, deleteAllDataSection]
	}

	// MARK: - Network requests
	func fetchRecords() {
		guard let id = userService.user?.remoteId else {
			return
		}
		isLoadingSubject.send(true)
		recordService.fetchRecords(userId: id)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					self.createBackupOrCSVFile()
					Logger.info("Finished")
				case .failure(let error):
					self.isLoadingSubject.send(false)
					Logger.error(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { [weak self] records in
				guard let self = self else {
					return
				}
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
		recordService.filterRecordsByDate(
			userId: id,
			startDate: startDate,
			endDate: endDate)

		.subscribe(on: DispatchQueue.global())
		.receive(on: DispatchQueue.main)
		.sink { [weak self] completion in
			guard let self = self else {
				return
			}
			switch completion {
			case .finished:
				self.createBackupOrCSVFile()
				Logger.info("Finished")
			case .failure(let error):
				self.isLoadingSubject.send(false)
				Logger.error(error.localizedDescription)
				errorSubject.send(error)
			}
		} receiveValue: { [weak self] records in
			guard let self = self else {
				return
			}
			self.records = records
			self.isLoadingSubject.send(false)
		}
		.store(in: &cancellables)
	}

	// MARK: - Create backup methods
	func createBackupFileIfNeeded(_ fileName: String) throws {
		guard let filePath = fileManager.urls(
			for: .documentDirectory,
			in: .userDomainMask).first else {
			return
		}

		let fileURL = filePath.appendingPathComponent(fileName).appendingPathExtension(MimeTypes.json)

		if !fileManager.fileExists(atPath: fileURL.path) {
			let data = Data()
			try data.write(to: fileURL)
		}
	}

	func setupFileURL() {
		guard let docDirectoryURL = fileManager.urls(
			for: .documentDirectory,
			in: .userDomainMask).first
		else {
			return
		}

		let fileNameDate = Date().stringRepresentation(format: .dayMonthYear)
		fileName = "\(Localization.appTitle)-\(fileNameDate)"
		let outputURL = docDirectoryURL.appendingPathComponent(fileName).appendingPathExtension(MimeTypes.json)
		self.outputURL = outputURL

		do {
			try createBackupFileIfNeeded(fileName)
		} catch let error {
			Logger.error(error.localizedDescription)
		}
	}

	func saveFile() {
		setupFileURL()

		do {
			let jsonEncoder = JSONEncoder()
			let jsonCodedData = try jsonEncoder.encode(records)
			guard let prettyJSON = jsonCodedData.prettyPrintedJSONString else {
				return
			}

			if let outputURL = outputURL {
				try prettyJSON.write(
					to: outputURL,
					atomically: true,
					encoding: String.Encoding.utf8)
			}
		} catch let error {
			Logger.error(error.localizedDescription)
			return
		}
	}

	// MARK: - Create .csv file for sharing data
	func buildRecordsDictionary() -> [[String: Any]] {
		var recordsResults: [[String: Any]] = []

		recordsResults = self.records.map { record in
			var recordsDictionary = [String: Any]()

			recordsDictionary.updateValue(
				record.recordDate.stringRepresentation(format: .dayMonthYearTime),
				forKey: CSVFileDictionaryKeys.recordDate)

			recordsDictionary.updateValue(
				record.glucoseLevel?.convertToString() ?? "",
				forKey: CSVFileDictionaryKeys.glucose)

			recordsDictionary.updateValue(
				record.fastInsulin?.convertToString() ?? "",
				forKey: CSVFileDictionaryKeys.fastInsulin)

			recordsDictionary.updateValue(
				record.longInsulin?.convertToString() ?? "",
				forKey: CSVFileDictionaryKeys.longInsulin)

			recordsDictionary.updateValue(
				record.meal?.convertToString() ?? "",
				forKey: CSVFileDictionaryKeys.meal)

			recordsDictionary.updateValue(
				record.recordNote ?? "",
				forKey: CSVFileDictionaryKeys.note)

			return recordsDictionary
		}
		return recordsResults
	}

	func createCSV() {
		let newLine = "\r\n"
		let recordsDictionaries = buildRecordsDictionary()

		var csvString = createCVSString()
		_ = recordsDictionaries.map { dct in
			guard
				let dateString = dct[CSVFileDictionaryKeys.recordDate],
				let glucose = dct[CSVFileDictionaryKeys.glucose],
				let fastInsulin = dct[CSVFileDictionaryKeys.fastInsulin],
				let longInsulin = dct[CSVFileDictionaryKeys.longInsulin],
				let meal = dct[CSVFileDictionaryKeys.meal],
				let note = dct[CSVFileDictionaryKeys.note]
			else {
				return
			}
			csvString = csvString.appending("\(dateString) , \(glucose) , \(fastInsulin) , \(longInsulin) , \(meal) , \(note)\(newLine)")
		}

		do {
			let path = try fileManager.url(
				for: .documentDirectory,
				in: .userDomainMask,
				appropriateFor: nil,
				create: false)

			let fileURL = path.appendingPathComponent(
				Localization.sharedFileName,
				conformingTo: .commaSeparatedText)

			try csvString.write(
				to: fileURL,
				atomically: true,
				encoding: .utf8)
			
			attachmentURL = fileURL
		} catch {
			assert(false, "Error occured")
		}
	}

	func createBackupOrCSVFile() {
		guard let currentAction = currentAction else {
			return
		}

		switch currentAction {
		case .backup:
			saveFile()
		case .share:
			createCSV()
		}
	}

	func createCVSString() -> String {
		let newLine = "\r\n"
		let comma = ","
		let space = " "
		var csvString = ""
		[
			Localization.date,
			comma, space,
			Localization.glucose,
			comma, space,
			Localization.fastActingInsulin,
			comma, space,
			Localization.basalInsulin,
			comma, space,
			Localization.meal,
			comma, space,
			Localization.notes,
			newLine, newLine,
			newLine, newLine,
			newLine
		].forEach { csvString.append($0) }

		return csvString
	}
}

private enum CSVFileDictionaryKeys {
	static let recordDate = "recordDate"
	static let glucose = "glucose"
	static let fastInsulin = "fastInsulin"
	static let longInsulin = "longInsulin"
	static let meal = "meal"
	static let note = "note"
}
