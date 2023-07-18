//
//  DataSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.07.2023.
//

import Foundation
import Combine

final class DataSceneViewModel: BaseViewModel {
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<DataSceneTransitions, Never>()
}
