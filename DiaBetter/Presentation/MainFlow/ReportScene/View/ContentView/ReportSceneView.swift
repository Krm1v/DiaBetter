//
//  ReportSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.03.2023.
//

import UIKit
import Combine

final class ReportSceneView: BaseView {
	// MARK: - UI Elements
	private lazy var mockLabel = buildTitleLabel(with: "This screen is in progress now.", fontSize: 17)

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
private extension ReportSceneView {
	func setupUI() {
		backgroundColor = .black
		setupLayout()
	}

	func setupLayout() {
		addSubview(mockLabel, constraints: [
			mockLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			mockLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
}
