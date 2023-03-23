//
//  SettingsSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.03.2023.
//

import Foundation
import Combine

final class SettingsSceneViewModel: BaseViewModel {
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<SettingsTransition, Never>()
	
	override func onViewDidLoad() {}
	
	//MARK: - Public methods
	func openUserSettings(_ object: Settings?) {
		transitionSubject.send(.userScene)
	}
}
