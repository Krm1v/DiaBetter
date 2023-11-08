//
//  ChartsViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.10.2023.
//

import Foundation
import Combine

internal class ChartsViewModel: BaseViewModel {
    // MARK: - Properties
    let recordsService: RecordsService
    let userService: UserService
    let settingsService: SettingsService
    let unitsConvertManager: UnitsConvertManager
    
    @Published var currentSettings: AppSettingsModel?
    @Published var modifiedRecords: [Record] = []
    @Published var records: [Record] = []
    
    // MARK: - Init
    init(
        recordsService: RecordsService,
        userService: UserService,
        settingsService: SettingsService,
        unitsConvertManager: UnitsConvertManager
    ) {
        self.recordsService = recordsService
        self.userService = userService
        self.settingsService = settingsService
        self.unitsConvertManager = unitsConvertManager
    }
    
    // MARK: - Overriden methods
    override func onViewDidLoad() {
        fetchRecordsRequest()
    }
}

// MARK: - Private extension
private extension ChartsViewModel {
    func getCurrentSettings() {
        let combinedData = Publishers.CombineLatest(settingsService.settingsPublisher, $records)
        combinedData
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings, records in
                guard let self = self else {
                    return
                }
                self.currentSettings = settings
                self.modifiedRecords = records.compactMap({ record in
                    var modifiedRecord = record
                    
                    if let glucose = record.glucoseLevel {
                        modifiedRecord.glucoseLevel = self.unitsConvertManager.convertRecordUnits(
                            glucoseValue: glucose)
                    }
                    
                    if let carbs = record.meal {
                        modifiedRecord.meal = self.unitsConvertManager.convertRecordUnits(
                            carbs: carbs)
                    }
                    
                    return modifiedRecord
                })
            }
            .store(in: &cancellables)
    }
    
    func fetchRecordsRequest() {
        guard let userId = userService.user?.remoteId else {
            return
        }
        recordsService.fetchRecords(userId: userId)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {
                    return
                }
                switch completion {
                case .finished:
                    Logger.info("Records did fetch")
                    fetchRecords()
                case .failure(let error):
                    Logger.error(error.localizedDescription)
                    errorSubject.send(error)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func fetchRecords() {
        recordsService.recordsPublisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                guard let self = self else {
                    return
                }
                self.records = records
                getCurrentSettings()
            }
            .store(in: &cancellables)
    }
}
