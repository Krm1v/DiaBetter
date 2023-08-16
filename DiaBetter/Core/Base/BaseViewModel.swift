//
//  BaseViewModel.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 24.10.2021.
//

import Combine

protocol ViewModel {
	var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
	var errorPublisher: AnyPublisher<Error, Never> { get }
	var infoPublisher: AnyPublisher<(String, String), Never> { get }

	func onViewDidLoad()
	func onViewWillAppear()
	func onViewDidAppear()
	func onViewWillDisappear()
	func onViewDidDisappear()
}

internal class BaseViewModel: ViewModel {
	// MARK: - Properties
	var cancellables = Set<AnyCancellable>()
	private(set) lazy var isLoadingPublisher = isLoadingSubject.eraseToAnyPublisher()
	let isLoadingSubject = PassthroughSubject<Bool, Never>()
	private(set) lazy var errorPublisher = errorSubject.eraseToAnyPublisher()
	let errorSubject = PassthroughSubject<Error, Never>()
	private(set) lazy var infoPublisher = infoSubject.eraseToAnyPublisher()
	let infoSubject = PassthroughSubject<(String, String), Never>()

	// MARK: - Public methods
	func onViewDidLoad() {}
	func onViewWillAppear() {}
	func onViewDidAppear() {}
	func onViewWillDisappear() {}
	func onViewDidDisappear() {}

	// MARK: - Deinit
	deinit {
		debugPrint("deinit of ", String(describing: self))
	}
}
