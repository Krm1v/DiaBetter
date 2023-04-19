//
//  PermissionService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 23.03.2023.
//

import UIKit
import PhotosUI
import Combine

protocol PermissionService {
	var permissionPublisher: AnyPublisher<PHAuthorizationStatus, Never> { get }
	
	func askForPermissions()
}

final class PermissionServiceImpl: PermissionService {
	//MARK: - Piblishers
	private(set) lazy var permissionPublisher = permissionSubject.eraseToAnyPublisher()
	private let permissionSubject = PassthroughSubject<PHAuthorizationStatus, Never>()
	
	//MARK: - Public methods
	func askForPermissions() {
		PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] status in
			DispatchQueue.main.async { [unowned self] in
				self.checkAuthorizationStatus(for: status)
			}
		}
	}
}

//MARK: - Private extension
private extension PermissionServiceImpl {
	func checkAuthorizationStatus(for status: PHAuthorizationStatus) {
		switch status {
		case .authorized:
			permissionSubject.send(.authorized)
		case .limited:
			permissionSubject.send(.limited)
		case .restricted:
			permissionSubject.send(.restricted)
		case .notDetermined:
			permissionSubject.send(.notDetermined)
		case .denied:
			permissionSubject.send(.denied)
		@unknown default:
			break
		}
	}
}
