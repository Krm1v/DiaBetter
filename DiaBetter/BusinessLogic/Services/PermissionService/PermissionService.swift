//
//  PermissionService.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 23.03.2023.
//

import UIKit
import Combine
import PhotosUI
import UserNotifications

protocol PermissionService {
	var photoPermissonPublisher: AnyPublisher<PHAuthorizationStatus, Never> { get }
	
	func askForPhotoPermissions()
	func askForNotificationsPermissions() -> Future<Bool, Error>
}

final class PermissionServiceImpl: PermissionService {
	//MARK: - Piblishers
	private(set) lazy var photoPermissonPublisher = photoPermissionSubject.eraseToAnyPublisher()
	private let photoPermissionSubject = PassthroughSubject<PHAuthorizationStatus, Never>()
	private let userNotificationCenter = UNUserNotificationCenter.current()
	
	//MARK: - Public methods
	func askForPhotoPermissions() {
		PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] status in
			DispatchQueue.main.async { [unowned self] in
				self.checkAuthorizationStatus(for: status)
			}
		}
	}
	
	func askForNotificationsPermissions() -> Future<Bool, Error> {
		return Future<Bool, Error> { [weak self] promise in
			guard let self = self else { return }
			self.userNotificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
				if let error = error {
					promise(.failure(error))
					NetworkLogger.error(error.localizedDescription, shouldLogContext: true)
				} else {
					promise(.success(granted))
					self.userNotificationCenter.getNotificationSettings { (settings) in
						switch settings.authorizationStatus {
						case .authorized:
							debugPrint("Authorized")
						default: debugPrint("Unauthorized")
						}
						guard settings.authorizationStatus == .authorized else { return }
					}
				}
			}
		}
	}
}

//MARK: - Private extension
private extension PermissionServiceImpl {
	func checkAuthorizationStatus(for status: PHAuthorizationStatus) {
		switch status {
		case .authorized:
			photoPermissionSubject.send(.authorized)
		case .limited:
			photoPermissionSubject.send(.limited)
		case .restricted:
			photoPermissionSubject.send(.restricted)
		case .notDetermined:
			photoPermissionSubject.send(.notDetermined)
		case .denied:
			photoPermissionSubject.send(.denied)
		@unknown default:
			break
		}
	}
}

