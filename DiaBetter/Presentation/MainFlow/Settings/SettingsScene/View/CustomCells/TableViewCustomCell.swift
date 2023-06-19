//
//  TableViewCustomCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.03.2023.
//

import UIKit

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

//MARK: - Private extension
private extension TableViewCustomCell {
	func setupCell() {
		backgroundColor = Colors.darkNavyBlue.color
		selectionStyle = .none
		separatorInset = UIEdgeInsets(top: .zero,
									  left: Constants.defaultEdgeInset,
									  bottom: .zero,
									  right: Constants.defaultEdgeInset)
		textLabel?.font = FontFamily.Montserrat.semiBold.font(size: Constants.defaultFontSize)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let defaultEdgeInset: CGFloat = 8
	static let defaultFontSize:  CGFloat = 17
}
