//
//  ReportViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.03.2023.
//

import Foundation
import Combine

final class ReportViewModel: BaseViewModel {
	// MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<ReportTransition, Never>()
}
