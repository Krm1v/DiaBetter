//
//  AddRecordSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine

final class AddRecordSceneViewModel: BaseViewModel {
	typealias Section = SectionModel<RecordParameterSections, RecordParameterItems>

	// MARK: - Properties
	private(set) lazy var transitionPiblisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<AddRecordSceneTransition, Never>()
	private let recordsService: RecordsService
	private let userService: UserService
	private var isInputEmpty = false

	// MARK: - @Publisher properties
	@Published var glucoseLvl: Decimal?
	@Published var meal: Decimal?
	@Published var fastInsulin: Decimal?
	@Published var longInsulin: Decimal?
	@Published var note = ""
	@Published var date = Date()
	@Published var sections: [Section] = []

	// MARK: - Init
	init(recordsService: RecordsService, userService: UserService) {
		self.recordsService = recordsService
		self.userService = userService
	}

	// MARK: - Overriden methods
	override func onViewDidLoad() {
		checkValidation()
		updateDatasource()
	}

	// MARK: - Public methods
	func closeAddRecordScene() {
		transitionSubject.send(.success)
	}

	func checkValidation() {
		$glucoseLvl.combineLatest($meal, $fastInsulin, $longInsulin)
			.map({ glucose, meal, fastInsulin, longInsulin in
				guard
					!(glucose?.convertToString().isEmpty ?? true) ||
					!(meal?.convertToString().isEmpty ?? true) ||
					!(fastInsulin?.convertToString().isEmpty ?? true) ||
					!(longInsulin?.convertToString().isEmpty ?? true)
				else { return false }
				return true
			})
			.sink { [unowned self] in isInputEmpty = $0  }
			.store(in: &cancellables)
	}

	func saveRecord() {
		let error = NSError(domain: "",
							code: .zero,
							userInfo: [NSLocalizedDescriptionKey: Localization.addNewRecordErrorDescription])
		isInputEmpty ? addNewRecord() : errorSubject.send(error)
	}
}

// MARK: - Private extension
private extension AddRecordSceneViewModel {
	func updateDatasource() {
		let glucose = GlucoseLevelOrMealCellModel(
			title: Localization.glucose,
			parameterTitle: Localization.glucose,
			textfieldValue: Constants.textFieldDefaultPlaceholder,
			unitsTitle: GlucoseLevelUnits.mmolL.description,
			currentField: .glucose)

		let meal = GlucoseLevelOrMealCellModel(
			title: Localization.meal,
			parameterTitle: Localization.meal,
			textfieldValue: Constants.textFieldDefaultPlaceholder,
			unitsTitle: MealUnits.breadUnits.description,
			currentField: .meal)

		let insulin = InsulinCellModel(
			title: Localization.insulin,
			parameterTitleForFastInsulin: Localization.fastActingInsulin,
			parameterTitleForBasalInsulin: Localization.basalInsulin,
			fastInsulinTextfieldValue: Constants.textFieldDefaultPlaceholder,
			basalInsulinTextFieldValue: Constants.textFieldDefaultPlaceholder,
			unitsTitleForFastInsulin: Constants.unitsDefaultPlaceholder,
			unitsTitleForBasalInsulin: Constants.unitsDefaultPlaceholder)

		let note = NoteCellModel(
			title: Localization.notes,
			textViewValue: Localization.howDoYouFeel)

		let dateSectionModel = DatePickerCellModel(title: Localization.date)
		let dateSection = Section(
			section: .date,
			items: [
				.date(dateSectionModel)
			])

		let mainSection = Section(
			section: .main,
			items: [
				.glucoseLevelOrMeal(glucose),
				.glucoseLevelOrMeal(meal)
			])

		let insulinSection = Section(
			section: .insulin,
			items: [
				.insulin(insulin)
			])

		let noteSection = Section(
			section: .note,
			items: [
				.note(note)
			])

		let buttonsSection = Section(
			section: .buttons,
			items: [
				.buttons
			])

		sections = [dateSection, mainSection, insulinSection, noteSection, buttonsSection]
	}

	// MARK: - Network requests
	func addNewRecord() {
		guard let record = setupNewRecord() else {
			return
		}
		isLoadingSubject.send(true)
		recordsService.addRecord(record: record)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					Logger.info("Finished")
					isLoadingSubject.send(false)
					self.closeAddRecordScene()
				case .failure(let error):
					Logger.error(error.localizedDescription)
					isLoadingSubject.send(false)
					errorSubject.send(error)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}

	// MARK: - Helpers methods
	func setupNewRecord() -> Record? {
		guard let userId = userService.user?.remoteId else {
			return nil
		}
		let record = Record(
			meal: meal,
			fastInsulin: fastInsulin,
			glucoseLevel: glucoseLvl,
			longInsulin: longInsulin,
			objectId: UUID().uuidString,
			recordDate: date,
			recordNote: note,
			userId: userId)

		return record
	}
}

// MARK: - Constants
private enum Constants {
	static let textFieldDefaultPlaceholder = "000"
	static let unitsDefaultPlaceholder = 	 "u."
}
