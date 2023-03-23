//
//  SettingsTableView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.03.2023.
//

import UIKit
import Combine

final class SettingsTableView: UITableView {
	//MARK: - Properties
	private var diffableDataSource: SettingsTableViewDiffableDataSource?
	private var cancellables = Set<AnyCancellable>()
	private let sections = SettingsGroup.allCases
	
	//MARK: - Init
	override init(frame: CGRect, style: UITableView.Style) {
		super.init(frame: frame, style: style)
		setupTable()
		
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupTable()
	}
	
	func getObject(with indexPath: IndexPath) -> Settings? {
		diffableDataSource?.itemIdentifier(for: indexPath)
	}
	
	func reloadDiffableDatasourceData() {
		var snapshot = NSDiffableDataSourceSnapshot<SettingsGroup, Settings>()
		sections.forEach { section in
			snapshot.appendSections([section])
			snapshot.appendItems(section.group, toSection: section)
		}
		diffableDataSource?.apply(snapshot, animatingDifferences: true)
	}
}


//MARK: - Private extension
private extension SettingsTableView {
	//MARK: - DiffableDatasource
	func setupDiffableDatasource() {
		diffableDataSource = SettingsTableViewDiffableDataSource(tableView: self,
																 cellProvider: { (tableView, indexPath, identifier) -> TableViewCustomCell? in
			guard let section = SettingsGroup(rawValue: indexPath.section) else { return nil }
			switch section {
			case .general:
				let cell = self.configureCell(cellType: TableViewCustomCell.self,
										  with: identifier.title,
										  indexPath: indexPath)
				cell.configure(with: section.group, indexPath: indexPath.row)
				return cell
			case .customization:
				let cell = self.configureCell(cellType: TableViewCustomCell.self,
										  with: identifier.title,
										  indexPath: indexPath)
				cell.configure(with: section.group, indexPath: indexPath.row)
				return cell
			case .about:
				let cell = self.configureCell(cellType: TableViewCustomCell.self,
										  with: identifier.title,
											  indexPath: indexPath)
				cell.configure(with: section.group, indexPath: indexPath.row)
				return cell
			case .empty:
				let cell = self.configureCell(cellType: TableViewCustomCell.self,
										  with: identifier.title,
										  indexPath: indexPath)
				cell.configure(with: section.group, indexPath: indexPath.row)
				return cell
			}
		})
	}
	
	//MARK: - SetupUI
	func setupTable() {
		register(TableViewCustomCell.self, forCellReuseIdentifier: Constants.reuseId)
		backgroundColor = .white
		setupDiffableDatasource()
		reloadDiffableDatasourceData()
	}
	
	func configureCell<T: SelfConfiguringTableViewCell>(cellType: T.Type,
														with: String,
														indexPath: IndexPath) -> T {
		guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseID,
											 for: indexPath) as? T else {
			fatalError("Error \(cellType)")
		}
		return cell
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let reuseId = "settingsTableViewCell"
}
