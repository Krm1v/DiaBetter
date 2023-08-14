//
//  CreditsSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.06.2023.
//

import Foundation
import Combine

final class CreditsSceneViewModel: BaseViewModel {
	typealias CreditsSection = SectionModel<CreditsSceneSections, CreditsSceneItems>
	
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<CreditsSceneTransitions, Never>()
	@Published var sections: [CreditsSection] = []
	
	//MARK: - Overriden methods
	override func onViewWillAppear() {
		updateDatasource()
	}
}

//MARK: - Private extension
private extension CreditsSceneViewModel {
	func updateDatasource() {
		guard let appIcon = getAppIconImage() else { return }
		guard let appVersion = Bundle.main.releaseVersionNumber else { return }
		guard let buildVersion = Bundle.main.buildVersionNumber else { return }
		let appInfoModel = AppInfoCellModel(appIcon: appIcon,
											appVersion: "v.\(appVersion)",
											buildVersion: "Build: \(buildVersion)",
											companyInfo: "CHI Software")
		
		let appInfoSection = CreditsSection(section: .appInfoSection, items: [.appInfoItem(appInfoModel)])
		
		let socialMediaSection = CreditsSection(
			section: .socialMediaSection,
			items:
				[
					.listItem(CreditsListCellModel(title: Localization.visitWebsite, item: .website)),
					.listItem(CreditsListCellModel(title: Localization.followInstagram, item: .instagram)),
					.listItem(CreditsListCellModel(title: Localization.followTwitter, item: .twitter)),
					.listItem(CreditsListCellModel(title: Localization.followFb, item: .fb)),
					.listItem(CreditsListCellModel(title: Localization.followLinkedIn, item: .linkedIn))
				]
		)
		
		let termsAndConditionsSection = CreditsSection(
			section: .termsAndConditionsSection,
			items:
				[
					.listItem(CreditsListCellModel(title: Localization.termsAndConditions, item: .termsAndConditions)),
					.listItem(CreditsListCellModel(title: Localization.privacyPolicy, item: .privacyPolicy))
				]
		)
		sections = [appInfoSection, socialMediaSection, termsAndConditionsSection]
	}
}
