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
	
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<BackupSceneTransitions, Never>()
	@Published var sections: [SectionModel<BackupSceneSections, BackupSceneItems>] = []
	@Published var startDate = Date()
	@Published var endDate = Date()
	
	//MARK: - Overriden methods
	override func onViewWillAppear() {
		updateDatasource()
	}
}

//MARK: - Private extension
private extension BackupSceneViewModel {
	func updateDatasource() {
		let startDateModel = BackupDateCellModel(title: Localization.startDate,
												 date: startDate,
												 item: .startDate)
		let endDateModel = BackupDateCellModel(title: Localization.endDate,
											   date: endDate,
											   item: .endDate)
		let allDataBackupModel = BackupShareCellModel(title: Localization.backupAllData,
													  color: .largeTitle,
													  item: .backupAllData)
		let dateSectionModel = BackupSectionModel(title: Localization.pickDateRangeFooterText)
		let backupDateSection = Section(section: .backupDateSection(dateSectionModel), items: [
			.datePickerItem(startDateModel),
			.datePickerItem(endDateModel),
			.plainItem(allDataBackupModel)
		])
		
		let backupModel = BackupShareCellModel(title: Localization.createBackup,
											   color: .regular,
											   item: .createBackup)
		let shareModel = BackupShareCellModel(title: Localization.shareData,
											  color: .regular,
											  item: .shareData)
		let shareSectionModel = BackupSectionModel(title: Localization.backupOrShareFooterText)
		let shareSection = Section(section: .shareSection(shareSectionModel), items: [
			.plainItem(backupModel),
			.plainItem(shareModel)
		])
		
		let deleteAllDataModel = BackupShareCellModel(title: Localization.eraseAllData,
													  color: .alert,
													  item: .eraseAllData)
		let deleteSectionModel = BackupSectionModel(title: Localization.eraseDataFooterText)
		let deleteAllDataSection = Section(section: .eraseDataSection(deleteSectionModel), items: [
			.plainItem(deleteAllDataModel)
		])
		
		sections = [backupDateSection, shareSection, deleteAllDataSection]
	}
}

