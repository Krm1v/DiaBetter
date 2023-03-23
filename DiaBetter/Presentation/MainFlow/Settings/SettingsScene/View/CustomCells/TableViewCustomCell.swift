//
//  TableViewCustomCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.03.2023.
//

import UIKit

protocol SelfConfiguringTableViewCell: AnyObject {
	static var reuseID: String { get }
}

final class TableViewCustomCell: UITableViewCell {
	//MARK: - Init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupCell()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupCell()
	}
	
	//MARK: - Public methods
	func configure(with text: [Settings], indexPath: Int) {
		let title = text.map({ $0.title })
		textLabel?.text = title[indexPath]
	}
}

//MARK: - Extension SelfConfiguringTableViewCell
extension TableViewCustomCell: SelfConfiguringTableViewCell {
	static var reuseID: String {
		return Constants.reuseID
	}
}

//MARK: - Private extension
private extension TableViewCustomCell {
	func setupCell() {
		backgroundColor = .systemGray5
		selectionStyle = .none
		separatorInset = UIEdgeInsets(top: .zero, left: 8, bottom: .zero, right: 8)
		textLabel?.font = FontFamily.Montserrat.semiBold.font(size: 17)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let reuseID = "settingsTableViewCell"
}
