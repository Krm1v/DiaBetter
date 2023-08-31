//
//  DiarySceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.02.2023.
//

import Combine
import Foundation

final class DiarySceneViewModel: BaseViewModel {
	typealias DiarySection = SectionModel<DiarySceneSection, DiarySceneItem>

	// MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<DiarySceneTransition, Never>()
	private let recordService: RecordsService
	private let userService: UserService
	private let settingsService: SettingsService
	private let unitsConvertManager: UnitsConvertManager
	private var pageOffsetValue = 0

	// MARK: - @Published properties
	@Published var sections: [DiarySection] = []
	@Published var records: [Record] = []

	// MARK: - Init
	init(
		recordService: RecordsService,
		userService: UserService,
		settingsService: SettingsService,
		unitsConvertManager: UnitsConvertManager
	) {
		self.recordService = recordService
		self.userService = userService
		self.settingsService = settingsService
		self.unitsConvertManager = unitsConvertManager
	}

	// MARK: - Overriden methods
	override func onViewWillAppear() {
		fetchRecordsPage()
	}

	override func onViewDidDisappear() {
		sections.removeAll()
		records.removeAll()
		pageOffsetValue = 0
	}

	// MARK: - Public methods
	func didSelectItem(_ item: DiarySceneItem) {
		switch item {
		case .record(let cellModel):
			guard let model = records.first(where: { $0.objectId == cellModel.recordId }) else {
				return
			}
			transitionSubject.send(.edit(model))
		}
	}

	func loadItems() {
		fetchRecordsPage()
	}
}

// MARK: - Private extension
private extension DiarySceneViewModel {
	func fetchRecordsPage() {
		guard let userId = userService.user?.remoteId else {
			return
		}

		isLoadingSubject.send(true)
		recordService.fetchPaginatedRecords(
			userId: userId,
			pageSize: Constants.pageSizeValue,
			offset: pageOffsetValue)
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else {
					return
				}
				switch completion {
				case .finished:
					Logger.info("Records page fetched")
					self.isLoadingSubject.send(false)
					self.pageOffsetValue += 20
					self.updateDatasource()
				case .failure(let error):
					Logger.error(error.localizedDescription)
					self.errorSubject.send(error)
					self.isLoadingSubject.send(false)
				}
			} receiveValue: { [weak self] records in
				guard let self = self else {
					return
				}
				self.records.append(contentsOf: records)
			}
			.store(in: &cancellables)
	}

	func updateDatasource() {
		guard let user = userService.user else {
			return
		}
		let modifiedRecords = unitsConvertManager.convertRecordUnits(records: records)

		let orderedRecords = modifiedRecords.reduce(into: [DateRecord]()) { result, record in

			if let index = result.firstIndex(where: { $0.date.isSameDay(as: record.recordDate) }) {
				var model = DiaryRecordCellModel(record, user: user, settings: settingsService.settings)
				model.glucoseInfo = .init(
					value: record.glucoseLevel?.convertToString(),
					unit: settingsService.settings.glucoseUnits.title)
				
				model.mealInfo = .init(
					value: record.meal?.convertToString(),
					unit: settingsService.settings.carbohydrates.title)
				result[index].records.append(model)
			} else {
				result.append(
					.init(date: record.recordDate,
						  records: [DiaryRecordCellModel(record, user: user, settings: settingsService.settings)])
				)
			}
		}

		let sortedRecords = orderedRecords.sorted(by: { $0.date > $1.date })

		sections = sortedRecords.map { item in
			let headerModel = RecordSectionModel(title: item.date.stringRepresentation(format: .dayMonthYear))

			let sortedItems = item.records.sorted(by: { $0.time > $1.time })
			let section = DiarySection(
				section: .main(headerModel),
				items: sortedItems.map { .record($0) })

			return section
		}
	}
}

// MARK: - Constants
private enum Constants {
	static let pageSizeValue = 20
}
