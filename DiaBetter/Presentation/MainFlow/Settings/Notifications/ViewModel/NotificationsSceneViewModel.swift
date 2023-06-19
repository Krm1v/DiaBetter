//
//  NotificationsSceneViewModel.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import Foundation
import Combine

final class NotificationsSceneViewModel: BaseViewModel {
	//MARK: - Properties
	private(set) lazy var transitionPublisher = transitionSubject.eraseToAnyPublisher()
	private let transitionSubject = PassthroughSubject<NotificationsSceneTransitions, Never>()
	private(set) var permissionService: PermissionService
	private let notificationManager: UserNotificationManager
	
	//MARK: - @Published properties
	@Published var sections: [SectionModel<NotificationsSections, NotificationItems>] = []
	@Published var notificationsAreEnabled = false
	@Published var glucoseReminder = ReminderModel(type: .glucose, isOn: false, time: .init())
	@Published var insulinReminder = ReminderModel(type: .insulin, isOn: false, time: .init())
	@Published var mealReminder = ReminderModel(type: .meal, isOn: false, time: .init())
	
	//MARK: - Overriden methods
	override func onViewWillAppear() {
		updateDatasource()
	}
	
	//MARK: - Init
	init(permissionService: PermissionService, notificationManager: UserNotificationManager) {
		self.permissionService = permissionService
		self.notificationManager = notificationManager
	}
	
	//MARK: - Public methods
	func didChangedNotificationState(isOn: Bool, completion: @escaping () -> (Void)) {
		permissionService.askForNotificationsPermissions()
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] completion in
				switch completion {
				case .finished:
					Logger.info("Finished", shouldLogContext: true)
					self.notificationsAreEnabled = isOn
					self.updateDatasource()
				case .failure(let error):
					Logger.error(error.localizedDescription, shouldLogContext: true)
				}
			} receiveValue: { [unowned self] granted in
				if !granted {
					completion()
				}
			}
			.store(in: &cancellables)
	}
	
	func disableNotificationSwitch() {
		notificationsAreEnabled = false
		cancelAllNotifications()
		updateDatasource()
	}
	
	func didChangedState(for type: ReminderValueType, isOn: Bool) {
		switch type {
		case .glucose: glucoseReminder.isOn = isOn
		case .insulin: insulinReminder.isOn = isOn
		case .meal:    mealReminder.isOn = isOn
		}
		updateDatasource()
	}
	
	func didChangedTime(for type: ReminderValueType, time: Date, dayTime: ReminderDayTime) {
		switch type {
		case .glucose:
			switch dayTime {
			case .morning: glucoseReminder.time.morning = time
			case .day: 	   glucoseReminder.time.day = time
			case .evening: glucoseReminder.time.evening = time
			}
		case .insulin:
			switch dayTime {
			case .morning: insulinReminder.time.morning = time
			case .day: 	   insulinReminder.time.day = time
			case .evening: insulinReminder.time.evening = time
			}
		case .meal:
			switch dayTime {
			case .morning: mealReminder.time.morning = time
			case .day: 	   mealReminder.time.day = time
			case .evening: mealReminder.time.evening = time
			}
		}
		updateDatasource()
	}
	
	func setGlucoseReminder() {
		let time = createDateWithHoursAndMinutes(hours: 14, minutes: 30)
		debugPrint("Time: \(time)")
		debugPrint("reminder.time: \(glucoseReminder.time.morning)")
		let reminder = Reminder(time: glucoseReminder.time.morning,
								reminderType: .glucose,
								repeats: true)
		let task = Task(name: "Don't forget to check your glucose level",
						body: "It's time to make a measurement of glucose level",
						reminder: reminder)
		debugPrint(task)
		notificationManager.scheduleNotification(task: task)
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] completion in
				switch completion {
				case .finished:
					Logger.info("Finished", shouldLogContext: true)
				case .failure(let error):
					Logger.error(error.localizedDescription, shouldLogContext: true)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
}

//MARK: - Private extension
private extension NotificationsSceneViewModel {
	func updateDatasource() {
		var datasource: [SectionModel<NotificationsSections, NotificationItems>] = []
		
		// General notifications switch
		let notificationSectionModel = SwitcherCellModel(title: Localization.notifications,
														 isOn: notificationsAreEnabled)
		let notificationSection = SectionModel<NotificationsSections, NotificationItems>(section: .enabler,
																						 items: [.notificationsEnabler(notificationSectionModel)])
		datasource.append(notificationSection)
		
		guard notificationsAreEnabled else {
			sections = datasource
			return
		}
		
		var mainSectionItems: [NotificationItems] = []
		
		let glucoseSwitcherModel = SwitcherCellModel(title: Localization.checkGlucoseLevel, isOn: glucoseReminder.isOn)
		mainSectionItems.append(.reminderSwitch(type: .glucose, model: glucoseSwitcherModel))
		if glucoseReminder.isOn {
			mainSectionItems.append(contentsOf: [
				.reminder(type: .glucose, model: ReminderCellModel(dayTime: .morning, date: glucoseReminder.time.morning)),
				.reminder(type: .glucose, model: ReminderCellModel(dayTime: .day, date: glucoseReminder.time.day)),
				.reminder(type: .glucose, model: ReminderCellModel(dayTime: .evening, date: glucoseReminder.time.evening))
			])
		}
		
		let insulinSwitcherModel = SwitcherCellModel(title: Localization.insulinInjection, isOn: insulinReminder.isOn)
		mainSectionItems.append(.reminderSwitch(type: .insulin, model: insulinSwitcherModel))
		
		if insulinReminder.isOn {
			mainSectionItems.append(contentsOf: [
				.reminder(type: .insulin, model: ReminderCellModel(dayTime: .morning, date: insulinReminder.time.morning)),
				.reminder(type: .insulin, model: ReminderCellModel(dayTime: .day, date: insulinReminder.time.day)),
				.reminder(type: .insulin, model: ReminderCellModel(dayTime: .evening, date: insulinReminder.time.evening))
			])
		}
		
		let mealSwitcherModel = SwitcherCellModel(title: Localization.haveMeal, isOn: mealReminder.isOn)
		mainSectionItems.append(.reminderSwitch(type: .meal, model: mealSwitcherModel))
		
		if mealReminder.isOn {
			mainSectionItems.append(contentsOf: [
				.reminder(type: .meal, model: ReminderCellModel(dayTime: .morning, date: mealReminder.time.morning)),
				.reminder(type: .meal, model: ReminderCellModel(dayTime: .day, date: mealReminder.time.day)),
				.reminder(type: .meal, model: ReminderCellModel(dayTime: .evening, date: mealReminder.time.evening))
			])
		}
		
		let mainSection = SectionModel<NotificationsSections, NotificationItems>(section: .main,
																				 items: mainSectionItems)
		datasource.append(mainSection)
		
		sections = datasource
	}
	
	func cancelAllNotifications() {
		notificationManager.cancelAllNotifications()
			.sink { [unowned self] completion in
				switch completion {
				case .finished:
					Logger.info("Finished", shouldLogContext: true)
				case .failure(let error):
					Logger.error(error.localizedDescription, shouldLogContext: true)
				}
			} receiveValue: { _ in }
			.store(in: &cancellables)
	}
}
