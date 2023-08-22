//
//  NotificationsSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import UIKit
import Combine

enum NotificationsViewActions {
	case notificationsEnablerDidToggled(Bool)
	case reminderSwitchDidToggled(type: ReminderType, isOn: Bool)
	case reminderTimeDidChanged(type: ReminderType, time: Date, dayTime: ReminderDayTime)
	case saveButtonDidTapped
}

final class NotificationsSceneView: BaseView {
	typealias Datasource = NotificationsTableViewDiffableDataSource
	typealias Snapshot = NSDiffableDataSourceSnapshot<NotificationsSections, NotificationItems>

	// MARK: - UI Elements
	private let tableView = UITableView(frame: .zero, style: .insetGrouped)
	private lazy var saveButton = buildNavBarButton()

	// MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<NotificationsViewActions, Never>()
	private var datasource: Datasource?

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		setupTableView()
		setupBindings()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		setupTableView()
		setupBindings()
	}

	// MARK: - Public methods
	func setupSnapshot(sections: [SectionModel<NotificationsSections, NotificationItems>]) {
		var snapshot = Snapshot()
		for section in sections {
			snapshot.appendSections([section.section])
			snapshot.appendItems(section.items, toSection: section.section)
		}
		datasource?.apply(snapshot, animatingDifferences: false)
	}

	// Temp
	func setupSaveButton(for controller: UIViewController) {
		saveButton.style = .plain
		saveButton.title = Localization.save
		controller.navigationItem.rightBarButtonItem = saveButton
	}
}

// MARK: - Private extension
private extension NotificationsSceneView {
	func setupUI() {
		backgroundColor = .black
		tableView.separatorStyle = .none
		setupLayout()
	}

	func setupLayout() {
		addSubview(tableView, withEdgeInsets: .all(.zero))
	}

	func setupTableView() {
		tableView.register(
			SwitcherCell.self,
			forCellReuseIdentifier: SwitcherCell.reuseID)

		tableView.register(
			ReminderCell.self,
			forCellReuseIdentifier: ReminderCell.reuseID)

		tableView.rowHeight = Constants.basicRowHeight
		setupDatasource()
	}

	func setupDatasource() {
		datasource = NotificationsTableViewDiffableDataSource(
			tableView: tableView,
			cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
			guard let self = self else {
				return UITableViewCell()
			}

			switch item {
			case .notificationsEnabler(let model):
				let cell = tableView.configureCell(
					cellType: SwitcherCell.self,
					indexPath: indexPath)

				cell.configure(model)
				cell.actionPublisher
					.sink { [unowned self] action in
						switch action {
						case .switcherDidToggled(let isOn):
							self.actionSubject.send(.notificationsEnablerDidToggled(isOn))
						}
					}
					.store(in: &cell.cancellables)
				return cell

			case .reminderSwitch(let type, let model):
				let cell = tableView.configureCell(
					cellType: SwitcherCell.self,
					indexPath: indexPath)

				cell.configure(model)
				cell.actionPublisher
					.sink { [unowned self] action in
						switch action {
						case .switcherDidToggled(let isOn):
							self.actionSubject.send(.reminderSwitchDidToggled(type: type, isOn: isOn))
						}
					}
					.store(in: &cell.cancellables)
				return cell

			case .reminder(let type, let model):
				let cell = tableView.configureCell(
					cellType: ReminderCell.self,
					indexPath: indexPath)

				cell.configure(model)
				cell.actionPublisher
					.sink { [unowned self] action in
						switch action {
						case .datePickerValueDidChanged(let time):
							self.actionSubject.send(.reminderTimeDidChanged(
								type: type,
								time: time,
								dayTime: model.dayTime))
						}
					}
					.store(in: &cell.cancellables)
				return cell
			}
		})
	}

	func setupBindings() {
		saveButton.tapPublisher
			.map { NotificationsViewActions.saveButtonDidTapped }
			.subscribe(actionSubject)
			.store(in: &cancellables)
	}
}

// MARK: - Constants
private enum Constants {
	static let basicRowHeight: CGFloat = 45
}
