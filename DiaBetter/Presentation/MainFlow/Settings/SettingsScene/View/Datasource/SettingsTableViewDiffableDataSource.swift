//
//  SettingsTableViewDiffableDataSource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import UIKit

final class SettingsTableViewDiffableDataSource: UITableViewDiffableDataSource<SettingsGroup, Settings> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = SettingsGroup.allCases
        return sections[section].title
    }
}
