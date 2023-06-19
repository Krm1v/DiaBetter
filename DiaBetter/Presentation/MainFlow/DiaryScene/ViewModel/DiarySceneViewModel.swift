//
//  DiarySceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.02.2023.
//

import Combine
import Foundation

final class DiarySceneViewModel: BaseViewModel {
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<DiarySceneTransition, Never>()
	private let recordService: RecordsService
	private let userService: UserService
	
	//MARK: - @Published properties
	@Published var sections: [SectionModel<DiarySceneSection, DiarySceneItem>] = []
	@Published var records: [Record] = []
	
	//MARK: - Init
	init(recordService: RecordsService, userService: UserService) {
		self.recordService = recordService
		self.userService = userService
	}
	
	//MARK: - Overriden methods
	override func onViewWillAppear() {
		fetchRecords()
	}
	
	override func onViewDidDisappear() {
		sections.removeAll()
	}
	
	//MARK: - Public methods
	func updateDatasource() {
		guard let user = userService.user else { return }
		var orderedRecords: [DateRecord] = []
		
		for record in records {
			guard let recordDate = record.recordDate else { return }
			if let index = orderedRecords
				.firstIndex(where: { $0.date.isSameDay(as: recordDate) }) {
				orderedRecords[index].records.append(DiaryRecordCellModel(record, user: user))
			} else {
				orderedRecords.append(
					.init(date: recordDate,
						  records: [DiaryRecordCellModel(record, user: user)])
				)
			}
		}
		let sortedRecords = orderedRecords.sorted(by: { $0.date > $1.date })
		
		for item in sortedRecords {
			let headerModel = RecordSectionModel(title: item.date.stringRepresentation(format: .dayMonthYear))
			var section = SectionModel<DiarySceneSection, DiarySceneItem>(
				section: .main(headerModel),
				items: []
			)
			let sortedItems = item.records.sorted(by: { $0.time > $1.time })
			section.items = sortedItems.map { .record($0) }
			self.sections.append(section)
		}
	}
	
	func didSelectItem(_ item: DiarySceneItem) {
		switch item {
		case .record(let cellModel):
			guard let model = records.first(where: { $0.objectId == cellModel.id }) else {
				return
			}
			debugPrint(model.objectId)
			transitionSubject.send(.edit(model))
		}
	}
}

//MARK: - Private extension
private extension DiarySceneViewModel {
	func fetchRecords() {
		isLoadingSubject.send(true)
		guard let userId = userService.user?.remoteId else { return }
		recordService.fetchRecords(userId: userId)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				switch completion {
				case .finished:
					isLoadingSubject.send(false)
					Logger.info("Finished", shouldLogContext: true)
					self.updateDatasource()
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { [weak self] records in
				guard let self = self else { return }
				self.records = records
			}
			.store(in: &self.cancellables)
	}
}
