//
//  UnitsSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.06.2023.
//

import UIKit
import Combine

final class UnitsSceneViewController: BaseViewController<UnitsSceneViewModel> {
	// MARK: - Properties
	private let contentView = UnitsSceneView()

	// MARK: - UIView lifecycle
	override func loadView() {
		view = contentView
	}

	override func viewDidLoad() {
        setupBindings()
        updateDiffableDatasourceSnapshot()
		super.viewDidLoad()
	}

	// MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		title = Localization.units
		navigationItem.largeTitleDisplayMode = .always
		contentView.setupSaveButton(for: self)
	}
}

// MARK: - Private extension
private extension UnitsSceneViewController {
	func updateDiffableDatasourceSnapshot() {
		viewModel.$sections
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] sections in
				self.contentView.setupSnapshot(sections: sections)
			}
			.store(in: &cancellables)
	}

	func setupBindings() {
		contentView.actionPublisher
			.sink { [unowned self] actions in
				switch actions {
				case .glucoseUnitsDidChanged(let unit):
                    viewModel.glucoseUnitDidChange(unit)

				case .saveButtonDidTapped:
					viewModel.saveSettings()

				case .carbsMenuDidTapped(let carbs):
					viewModel.carbohydrates = carbs
					
				case .targetGlucoseValueDidChaged(let glucoseTargetValue, let object):
                    debugPrint("Target value: \(glucoseTargetValue)")
					viewModel.glucoseTargetDidChange(object, glucoseTargetValue)
				}
			}
			.store(in: &cancellables)
	}
}
