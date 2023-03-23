//
//  DiarySceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.02.2023.
//

import Combine
import KeychainAccess
import Foundation

final class DiarySceneViewModel: BaseViewModel {
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<DiarySceneTransition, Never>()
	
}
