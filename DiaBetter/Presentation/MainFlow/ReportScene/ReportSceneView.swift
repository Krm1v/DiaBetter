//
//  ReportSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.03.2023.
//

import UIKit
import Combine

final class ReportSceneView: BaseView {
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
}

//MARK: - Private extension
private extension ReportSceneView {
	func setupUI() {
		backgroundColor = .black
	}
}
