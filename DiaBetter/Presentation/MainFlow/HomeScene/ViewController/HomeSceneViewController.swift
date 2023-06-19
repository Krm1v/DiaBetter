//
//  HomeSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import UIKit

final class HomeSceneViewController: BaseViewController<HomeSceneViewModel> {
	//MARK: - Properties
	private let contentView = HomeSceneView()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupBindings()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateDiffableDatasourceSnapshot()
	}
	
	//MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		title = Localization.home
		contentView.setupAddNewRecordButton(for: self)
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
	}
}

//MARK: - Private extension
private extension HomeSceneViewController {	
	func updateDiffableDatasourceSnapshot() {
		viewModel.$sections
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] sections in
				self.contentView.setupSnapshot(with: sections)
			}
			.store(in: &cancellables)
	}
	
	func setupBindings() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .addRecordButtonTapped:
					viewModel.openAddNewRecordScene()
				case .didSelectLineChartState(let state):
					viewModel.didSelectLineChartState(state)
				}
			}
			.store(in: &cancellables)
	}
}
