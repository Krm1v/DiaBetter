//
//  DiaryDetailSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.06.2023.
//

import Foundation
import Combine

final class DiaryDetailSceneViewModel: BaseViewModel {
	// MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<DiaryDetailSceneTransition, Never>()
	private let recordService: RecordsService
	private let settingsService: SettingsService
	private let unitsConvertManager: UnitsConvertManager
	private var modifiedRecord: Record?
	var record: Record

	// MARK: - @Published properties
	@Published var date = Date()
	@Published var glucose: Decimal?
	@Published var meal: Decimal?
	@Published var fastInsulin: Decimal?
	@Published var longInsulin: Decimal?
	@Published var note: String? = ""
	@Published var diaryDetailModel: DiaryDetailModel?

	// MARK: - Init
	init(
		record: Record,
		recordService: RecordsService,
		settingsService: SettingsService,
		unitsConvertManager: UnitsConvertManager
	) {
		self.record = record
		self.modifiedRecord = record
		self.recordService = recordService
		self.settingsService = settingsService
		self.unitsConvertManager = unitsConvertManager
		super.init()
	}

	// MARK: - Overriden methods
	override func onViewDidLoad() {
		getCurrentSettings()
	}

	override func onViewWillAppear() {
		setupInitialDateValue()
	}

	// MARK: - Public methods
	func updateRecord() {
		var record = updateRecordContent()
		unitsConvertManager.setToDefaultValue(glucoseValue: record.glucoseLevel)
			.combineLatest(unitsConvertManager.setToDefaultValue(carbs: record.meal))
			.receive(on: DispatchQueue.main)
			.sink { [weak self] (updatedGlucose, updatedCarbs) in
				guard let self = self else {
					return
				}
				record.glucoseLevel = updatedGlucose
				record.meal = updatedCarbs
				makeUpdateRecordRequest(record)
			}
			.store(in: &cancellables)
	}

	func deleteRecord() {
		makeDeleteRecordRequest()
	}
}

// MARK: - Private extension
private extension DiaryDetailSceneViewModel {
	// MARK: - Network requests
	func makeUpdateRecordRequest(_ record: Record) {
		isLoadingSubject.send(true)
		recordService.updateRecord(record: record, id: record.objectId)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					Logger.info("Record updated")
					self.isCompletedSubject.send(true)
					DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
						self.isCompletedSubject.send(false)
						self.transitionSubject.send(.backToDiary)
					}
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.errorSubject.send(error)
					self.isLoadingSubject.send(false)
				}
			} receiveValue: { [weak self] _ in
				guard let self = self else {
					return
				}
				self.isLoadingSubject.send(false)

			}
			.store(in: &cancellables)
	}

	func makeDeleteRecordRequest() {
		isLoadingSubject.send(true)
		recordService.deleteRecord(id: record.objectId)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					Logger.info("Record deleted")
					isCompletedSubject.send(true)
					DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
						self.isCompletedSubject.send(false)
						self.transitionSubject.send(.backToDiary)
					}
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.errorSubject.send(error)
					self.isLoadingSubject.send(false)
				}
			} receiveValue: { [weak self] in
				guard let self = self else {
					return
				}
				self.isLoadingSubject.send(false)
			}
			.store(in: &cancellables)
	}

	// MARK: - Datasource
	func updateDatasource() {
		guard let modifiedRecord = modifiedRecord else {
			return
		}
		diaryDetailModel = DiaryDetailModel(modifiedRecord)
	}

	// MARK: - Helpers
	func updateRecordContent() -> Record {
		let record = Record(
			meal: meal ?? self.record.meal,
			fastInsulin: fastInsulin ?? self.record.fastInsulin,
			glucoseLevel: glucose ?? self.record.glucoseLevel,
			longInsulin: longInsulin ?? self.record.longInsulin,
			objectId: record.objectId,
			recordDate: date,
			recordNote: note ?? record.recordNote,
			userId: self.record.userId)
		return record
	}

	func setupInitialDateValue() {
		self.date = record.recordDate
	}

	func getCurrentSettings() {
		settingsService.settingsPublisher
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] _ in

				if let glucose = record.glucoseLevel {
					self.modifiedRecord?.glucoseLevel = unitsConvertManager.convertRecordUnits(
						glucoseValue: glucose)
				}

				if let carbs = record.meal {
					self.modifiedRecord?.meal = unitsConvertManager.convertRecordUnits(
						carbs: carbs)
				}
				updateDatasource()
			}
			.store(in: &cancellables)
	}
}
