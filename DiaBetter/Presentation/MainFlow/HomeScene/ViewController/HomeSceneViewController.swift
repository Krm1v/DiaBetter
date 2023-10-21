//
//  HomeSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import UIKit
import SwiftUI

final class HomeSceneViewController: BaseViewController<HomeSceneViewModel> {
	// MARK: - UIView lifecycle methods
	override func viewDidLoad() {
		super.viewDidLoad()
        updateDatasource()
	}

	// MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		title = Localization.home
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
	}
}

// MARK: - Private extension
private extension HomeSceneViewController {
    func addHostingController(controller: UIHostingController<HomeSceneView>) {
        addChild(controller)
        view.addSubview(controller.view, constraints: [
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func updateDatasource() {
        viewModel.$homeSceneProps
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                guard let self = self else {
                    return
                }
                let controller = UIHostingController(
                    rootView: HomeSceneView(props: model))
                addHostingController(controller: controller)
                setupBindings(controller: controller)
            }
            .store(in: &cancellables)
    }
    
    func setupBindings(controller: UIHostingController<HomeSceneView>) {
        controller.rootView.actionPublisher
            .sink { [weak self] actions in
                guard let self = self else {
                    return
                }
                switch actions {
                case .addNewRecordButtonDidTapped:
                    viewModel.openAddNewRecordScene()
                }
            }
            .store(in: &cancellables)
    }
}
