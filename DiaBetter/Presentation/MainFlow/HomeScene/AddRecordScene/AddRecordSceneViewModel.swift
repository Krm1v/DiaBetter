//
//  AddRecordSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.03.2023.
//

import Foundation
import Combine

final class AddRecordSceneViewModel: BaseViewModel {
	private(set) lazy var transitionPiblisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<AddRecordSceneTransition, Never>()
	private let recordsService: RecordsService
	private let recordsNetworkService: RecordsNetworkService
	@Published var glucoseLvl: Decimal?
	@Published var meal: Decimal?
	@Published var fastInsulin: Decimal?
	@Published var longInsulin: Decimal?
	@Published var notes = ""
	@Published var date = Date()
	
	//MARK: - Init
	init(recordsService: RecordsService, recordsNetworkService: RecordsNetworkService) {
		self.recordsService = recordsService
		self.recordsNetworkService = recordsNetworkService
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
	
	func saveRecord() {
		let requestObject: (record: RecordRequestModel, token: String) = buildRequestModel()
		isLoadingSubject.send(true)
		recordsNetworkService.addRecord(record: requestObject.record, userToken: requestObject.token)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				guard let self = self else { return }
				self.isLoadingSubject.send(false)
				switch completion {
				case .finished:
					self.transitionSubject.send(.success)
				case .failure(let error):
					debugPrint(error.localizedDescription)
					self.errorSubject.send(error)
				}
			} receiveValue: { record in
				print(record.recordNote)
			}
			.store(in: &cancellables)
	}
}

//MARK: - Private extension
private extension AddRecordSceneViewModel {
	func buildRequestModel() -> (RecordRequestModel, String) {
		let currentDate = recordsService.convertDateToString(fromTimeStamp: date.timeIntervalSince1970)
		let record = RecordRequestModel(fastInsulin: fastInsulin,
										recordType: "main",
										longInsulin: longInsulin,
										recordNote: notes,
										glucoseLevel: glucoseLvl,
										meal: meal,
										recordDate: currentDate)
		guard let token = recordsService.token else {
			return (record, "no token")
		}
		return (record, token)
	}
}
