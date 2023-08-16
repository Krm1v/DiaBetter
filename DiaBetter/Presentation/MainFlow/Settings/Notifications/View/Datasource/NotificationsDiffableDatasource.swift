//
//  NotificationsDiffableDatasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.06.2023.
//

import UIKit

final class NotificationsTableViewDiffableDataSource: UITableViewDiffableDataSource<NotificationsSections, NotificationItems> {
	override func tableView(
		_ tableView: UITableView,
		titleForHeaderInSection section: Int
	) -> String? {
		let sections = NotificationsSections.allCases
		return sections[section].title
	}
}
