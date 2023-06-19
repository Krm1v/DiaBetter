//
//  PushNotificationsManager.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 15.06.2023.
//

import Foundation
import UserNotifications
import Combine

protocol UserNotificationManager: AnyObject {
	func scheduleNotification(task: Task) -> Future<Void, Error>
	func cancelNotification(with identirier: String) -> Future<Void, Error>
	func cancelAllNotifications() -> Future<Void, Error>
}

final class UserNotificationManagerImpl: NSObject {
	//MARK: - Properties
	private let userNotificationCenter = UNUserNotificationCenter.current()
	
	//MARK: - Init
	override init() {
		super.init()
		userNotificationCenter.delegate = self
	}
	
	//MARK: - Public methods
//	func scheduleNotification(task: Task) {
//		let content = UNMutableNotificationContent()
//		content.title = task.name
//		content.body = task.body
//		content.categoryIdentifier = task.id
//		let taskData = try? JSONEncoder().encode(task)
//		if let taskData = taskData {
//			content.userInfo = ["Task": taskData]
//		}
//		var trigger: UNNotificationTrigger?
//		let timeInterval = task.reminder.time.toDouble()
//		trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
//													repeats: task.reminder.repeats)
//		content.threadIdentifier = NotificationThreadIdentifiers.timeBasedNotificationThreadId.rawValue
//
//		if let trigger = trigger {
//			let request = UNNotificationRequest(
//				identifier: task.id,
//				content: content,
//				trigger: trigger
//			)
//			userNotificationCenter.add(request) { error in
//				if let error = error {
//					Logger.error(error.localizedDescription, shouldLogContext: true)
//				}
//			}
//		}
//	}
	
	func scheduleNotification(task: Task) -> Future<Void, Error> {
		return Future<Void, Error> { [weak self] promise in
			guard let self = self else { return }
			let content = UNMutableNotificationContent()
			content.title = task.name
			content.body = task.body
			content.sound = UNNotificationSound.default
			let calendar = Calendar.current
			let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.reminder.time)
			let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: task.reminder.repeats)
			let request = UNNotificationRequest(identifier: task.id,
												content: content,
												trigger: trigger)
			self.userNotificationCenter.add(request) { error in
				if let error = error {
					promise(.failure(error))
				} else {
					promise(.success(()))
				}
			}
			self.notificationDidSet(with: task.id)
		}
	}
	
	func cancelNotification(with identifier: String) -> Future<Void, Error> {
		return Future<Void, Error> { [weak self] promise in
			guard let self = self else { return }
			self.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
			promise(.success(()))
		}
	}
	
	func cancelAllNotifications() -> Future<Void, Error> {
		return Future<Void, Error> { [weak self] promose in
			guard let self = self else { return }
			self.userNotificationCenter.removeAllPendingNotificationRequests()
			promose(.success(()))
		}
	}
}

//MARK: - Private extension
private extension UserNotificationManagerImpl {
	func notificationDidSet(with identifier: String) {
		userNotificationCenter.getPendingNotificationRequests { notificationRequests in
			let isNotificationSet = notificationRequests.contains { $0.identifier == identifier }
			
			if isNotificationSet {
				print("Уведомление установлено.")
			} else {
				print("Уведомление не установлено.")
			}
		}
	}
}

//MARK: - Extension UserNotificationManager
extension UserNotificationManagerImpl: UserNotificationManager { }

//MARK: - Extension UNUserNotificationCenterDelegate
extension UserNotificationManagerImpl: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.list, .banner, .sound])
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		debugPrint("Received")
	}
}
