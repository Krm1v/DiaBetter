//
//  SettingsSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.03.2023.
//

import Foundation
import Combine

final class SettingsSceneViewModel: BaseViewModel {
    // MARK: - Properties
    private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
    private let transitionSubject = PassthroughSubject<SettingsTransition, Never>()
    
    // MARK: - Public methods
    func openDetailSettingsScreen(_ object: Settings) {
        switch object {
        case .user: 		 transitionSubject.send(.userScene)
        case .notifications: transitionSubject.send(.notificationsScene)
        case .data:			 transitionSubject.send(.dataScene)
        case .units: 		 transitionSubject.send(.unitsScene)
        case .credits: 		 transitionSubject.send(.creditsScene)
        default: break
        }
    }
}
