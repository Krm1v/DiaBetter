//
//  AddRecordSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine

enum RecordType: String {
	case noMeal
	case beforeMeal
	case afterMeal
}

final class AddRecordSceneViewModel: BaseViewModel {
	private(set) lazy var transitionPiblisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<AddRecordSceneTransition, Never>()
	private let recordsService: RecordsService
	@Published var glucoseLvl: Decimal?
	@Published var meal: Decimal?
	@Published var fastInsulin: Decimal?
	@Published var longInsulin: Decimal?
	@Published var notes = ""
	@Published var date = Date()
	@Published var sections: [SectionModel<RecordParameterSections, RecordParameterItems>] = []
	
	//MARK: - Init
	init(recordsService: RecordsService) {
		self.recordsService = recordsService
	}
	
	//MARK: - Overriden methods
	override func onViewDidLoad() {
		updateDatasource()
	}
	
	//MARK: - Public methods
	func setupDataFormat() -> String {
		let date = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMM YYYY hh:mm"
		let stringDate = formatter.string(from: date)
		return stringDate
	}
	
	func closeAddRecordScene() {
		transitionSubject.send(.success)
	}
	
	func addNewRecord() {
		guard let record = setupNewRecord() else { return }
		recordsService.addRecord(record: record)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					debugPrint("Finished")
					self.closeAddRecordScene()
				case .failure(let error):
					debugPrint(error)
					Logger.error(error.localizedDescription)
				}
			} receiveValue: { [weak self] record in
				guard let self = self else { return }
			}
			.store(in: &cancellables)
	}
	
	func updateDatasource() {
		let glucose = GlucoseLevelOrMealCellModel(title: Localization.glucose,
												  parameterTitle: Localization.glucose,
												  textfieldValue: "000",
												  unitsTitle: "mmol/L")
		let meal = GlucoseLevelOrMealCellModel(title: Localization.meal,
											   parameterTitle: Localization.meal,
											   textfieldValue: "000",
											   unitsTitle: "BU")
		let insulin = InsulinCellModel(title: Localization.insulin,
									   parameterTitleForFastInsulin: Localization.fastActingInsulin,
									   parameterTitleForBasalInsulin: Localization.basalInsulin,
									   fastInsulinTextfieldValue: "000",
									   basalInsulinTextFieldValue: "000",
									   unitsTitleForFastInsulin: "u.",
									   unitsTitleForBasalInsulin: "u.")
		let note = NoteCellModel(title: Localization.notes, textViewValue: "Note your feelings")
		let dateSectionModel = DatePickerCellModel(title: "Date")
		let dateSection = SectionModel<RecordParameterSections, RecordParameterItems>(section: .date, items: [.date(dateSectionModel)])
		let mainSection = SectionModel<RecordParameterSections, RecordParameterItems>(section: .main, items: [.glucoseLevelOrMeal(glucose), .glucoseLevelOrMeal(meal)])
		let insulinSection = SectionModel<RecordParameterSections, RecordParameterItems>(section: .unsulin, items: [.insulin(insulin)])
		let noteSection = SectionModel<RecordParameterSections, RecordParameterItems>(section: .note, items: [.note(note)])
		let buttonsSection = SectionModel<RecordParameterSections, RecordParameterItems>(section: .buttons, items: [.buttons])
		sections = [dateSection, mainSection, insulinSection, noteSection, buttonsSection]
	}
}

//MARK: - Private extension
private extension AddRecordSceneViewModel {
	func setupNewRecord() -> Record? {
		let record = Record(meal: meal,
							fastInsulin: fastInsulin,
							glucoseLevel: glucoseLvl,
							longInsulin: longInsulin,
							recordNote: notes,
							recordType: RecordType.noMeal.rawValue)
		return record
	}
}
