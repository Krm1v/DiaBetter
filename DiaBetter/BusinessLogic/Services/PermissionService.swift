//
//  PermissionService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 23.03.2023.
//

import UIKit
import PhotosUI
import Combine

enum PermissionType {
	case authorized
	case limited
	case restricted
	case notDetermined
	case denied
}

protocol PermissionService {
	var permissionPublisher: AnyPublisher<PermissionType, Never> { get }
	
	func askForPermissions()
	func moveToSettings()
}

final class PermissionServiceImpl: PermissionService {
	//MARK: - Piblishers
	private(set) lazy var permissionPublisher = permissionSubject.eraseToAnyPublisher()
	private let permissionSubject = PassthroughSubject<PermissionType, Never>()
	
	//MARK: - Public methods
	func askForPermissions() {
		PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] status in
			DispatchQueue.main.async { [unowned self] in
				self.checkAuthorizationStatus(for: status)
			}
		}
	}
	
	func moveToSettings() {
		guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
			assertionFailure("Not able to open App privacy settings")
			return
		}
		UIApplication.shared.open(url)
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
