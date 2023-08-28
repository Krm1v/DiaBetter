//
//  DiarySceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.02.2023.
//

import UIKit

final class DiarySceneViewController: BaseViewController<DiarySceneViewModel> {
	// MARK: - Properties
	private let contentView = DiarySceneView()

	// MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupBindings()
	}

	// MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		title = Localization.diary
		navigationItem.largeTitleDisplayMode = .always
	}
}

// MARK: - Private extension
private extension DiarySceneViewController {
	func setupBindings() {
		viewModel.$sections
			.sink { [unowned self] sections in
				self.contentView.setupSnapshot(sections: sections)
			}
			.store(in: &cancellables)

		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .didSelectItem(let item):
					viewModel.didSelectItem(item)
				case .didReachedBottom:
					viewModel.loadItems()
				}
			}
			.store(in: &cancellables)
	}
}
