//
//  BoxElementView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 26.04.2023.
//

import UIKit

final class BoxElementView: UIView {
	//MARK: - UIElements
	private lazy var valueLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = FontFamily.Montserrat.semiBold.font(size: 17)
		label.textAlignment = .natural
		label.textColor = .white
		label.minimumScaleFactor = 0.5
		return label
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .natural
		label.textColor = .systemGray
		label.font = FontFamily.Montserrat.regular.font(size: 13)
		label.minimumScaleFactor = 0.5
		return label
	}()
	
	private lazy var vStack = buildStackView(axis: .vertical,
											 alignment: .center,
											 distribution: .fillProportionally,
											 spacing: .zero)
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
	
	//MARK: - Public methods
	func setValue(titleLabel text: String) {
		titleLabel.text = text
	}
	
	func setValue(valueLabel text: String) {
		valueLabel.text = text
	}
	
	func setInfo(_ info: DiaryRecordCellModel.Info) {
		titleLabel.text = info.unit
		valueLabel.text = info.value
	}
}

//MARK: - Private extension
private extension BoxElementView {
	func setupUI() {
		self.backgroundColor = Colors.darkNavyBlue.color
		self.rounded(12)
		addSubs()
	}
	
	func addSubs() {
		addSubview(vStack, withEdgeInsets: .all(.zero))
		[valueLabel, titleLabel].forEach { vStack.addArrangedSubview($0) }
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let largeFontSize: CGFloat = 17
	static let regularFontSize: CGFloat = 13
}
