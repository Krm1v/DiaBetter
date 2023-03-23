//
//  ReportViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.03.2023.
//

import UIKit
import Combine

final class ReportViewController: BaseViewController<ReportViewModel> {
	//MARK: - Properties
	private let contentView = ReportSceneView()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.navigationBar.prefersLargeTitles = true
		title = Localization.report
	}
}
