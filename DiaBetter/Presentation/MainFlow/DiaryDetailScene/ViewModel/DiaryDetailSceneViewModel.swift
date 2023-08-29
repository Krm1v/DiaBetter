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
	var record: Record

	// MARK: - @Published properties
	@Published var date = Date()
	@Published var glucose: Decimal?
	@Published var meal: Decimal?
	@Published var fastInsulin: Decimal?
	@Published var longInsulin: Decimal?
	@Published var note: String? = ""

	// MARK: - Init
	init(record: Record, recordService: RecordsService) {
		self.record = record
		self.recordService = recordService
		super.init()
	}

	// MARK: - Public methods
	func updateRecord() {
		isLoadingSubject.send(true)
		recordService.updateRecord(record: updateRecordContent(), id: record.objectId)
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

	func deleteRecord() {
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

	func setupDatasource() -> DiaryDetailModel {
		return DiaryDetailModel(record)
	}
}

// MARK: - Private extension
private extension DiaryDetailSceneViewModel {
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
}
