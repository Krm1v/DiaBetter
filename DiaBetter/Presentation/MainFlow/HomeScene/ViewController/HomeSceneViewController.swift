//
//  HomeSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import UIKit
import SwiftUI
import Combine

final class HomeSceneViewController: BaseViewController<HomeSceneViewModel> {
    // MARK: - Properties
    private var hostingController: UIHostingController<HomeSceneView>?
    private var model: HomeSceneWidgetPropsModel?
    
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
    func updateDatasource() {
        viewModel.$homeSceneProps
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                guard let self = self else {
                    return
                }
                guard let model = model else {
                    return
                }
                hostingController = UIHostingController(
                    rootView: HomeSceneView(props: model))
                guard let hostingController = hostingController else {
                    return
                }
                addHostingController(hostingController)
                setupBindings(hostingController)
            }
            .store(in: &cancellables)
    }
    
    func addHostingController(
        _ controller: UIHostingController<HomeSceneView>
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            addChild(controller)
            view.addSubview(
                controller.view,
                constraints: [
                    controller.view.topAnchor.constraint(equalTo: view.topAnchor),
                    controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        }
    }
    
    func setupBindings(
        _ controller: UIHostingController<HomeSceneView>
    ) {
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
