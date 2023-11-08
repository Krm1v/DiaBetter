//
//  DiarySceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.02.2023.
//

import Combine
import Foundation

final class DiarySceneViewModel: BaseViewModel {
    // MARK: - Typealiases
    typealias DiarySection = SectionModel<DiarySceneSection, DiarySceneItem>
    
    // MARK: - Properties
    private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
    private let transitionSubject = PassthroughSubject<DiarySceneTransition, Never>()
    private let recordService: RecordsService
    private let unitsConvertManager: UnitsConvertManager
    private let userService: UserService
    private let settingsService: SettingsService
    private var pageOffsetValue = 0
    private var currentSettings: AppSettingsModel?
    private var modifiedRecords: [Record] = []
    
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
    override func onViewDidLoad() {
        getCurrentSettings()
    }
    
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
            guard let record = records.first(where: { $0.objectId == cellModel.recordId }) else {
                return
            }
            transitionSubject.send(.edit(record))
        }
    }
    
    func loadItems() {
        fetchRecordsPage()
    }
}

// MARK: - Private extension
private extension DiarySceneViewModel {
    // MARK: - Network requests
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
    
    // MARK: - Datasource
    func updateDatasource() {
        guard
            let user = userService.user,
            let currentSettings = currentSettings
        else {
            return
        }
        
        let orderedRecords = modifiedRecords.reduce(into: [DateRecord]()) { result, record in
            if let index = result.firstIndex(where: { $0.date.isSameDay(as: record.recordDate) }) {
                
                var model = DiaryRecordCellModel(record, user: user, settings: currentSettings)
                model.glucoseInfo = .init(
                    value: record.glucoseLevel?.convertToString() ?? "∅",
                    unit: currentSettings.glucoseUnits.title)
                
                model.mealInfo = .init(
                    value: record.meal?.convertToString(),
                    unit: currentSettings.carbohydrates.title)
                
                result[index].records.append(model)
            } else {
                result.append(
                    .init(
                        date: record.recordDate,
                        records: [DiaryRecordCellModel(
                            record, user: user,
                            settings: settingsService.settings)
                        ])
                )
            }
        }
        
        let sortedRecords = orderedRecords.sorted(by: { $0.date > $1.date })
        
        sections = sortedRecords.map { item in
            let headerModel = RecordSectionModel(
                title: item.date.stringRepresentation(format: .dayMonthYear))
            
            let sortedItems = item.records.sorted(by: { $0.time > $1.time })
            let section = DiarySection(
                section: .main(headerModel),
                items: sortedItems.map { .record($0) })
            
            return section
        }
    }
    
    // MARK: - Helpers
    func getCurrentSettings() {
        let combinedData = Publishers.CombineLatest(settingsService.settingsPublisher, $records)
        combinedData
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
                updateDatasource()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Constants
private enum Constants {
    static let pageSizeValue = 20
}
