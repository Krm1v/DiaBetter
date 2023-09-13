//
//  BaseHeaderSupplementaryView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 13.09.2023.
//
import UIKit

internal class BaseHeaderSupplementaryView: UICollectionReusableView {
	// MARK: - UI Elements
	private lazy var titleLabel = buildFieldTitleLabel()

	// MARK: - Properties
	var titleText: String? {
		get { return titleLabel.text }
		set { titleLabel.text = newValue }
	}

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
}

// MARK: - Private extension
private extension BaseHeaderSupplementaryView {
	func setupUI() {
		addSubs()
		titleLabel.text = titleText
		titleLabel.textColor = .white
		titleLabel.font = FontFamily.Montserrat.regular.font(size: 17)
		titleLabel.numberOfLines = .zero
	}

	func addSubs() {
		addSubview(titleLabel, withEdgeInsets: .init(top: .zero,
													 left: 16,
													 bottom: .zero,
													 right: .zero))
	}
}

// MARK: - Extension UIElementsBuilder
extension BaseHeaderSupplementaryView: UIElementsBuilder { }

