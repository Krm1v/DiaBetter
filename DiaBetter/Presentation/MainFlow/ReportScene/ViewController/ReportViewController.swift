//
//  ReportViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.03.2023.
//

import SwiftUI
import UIKit
import Combine

final class ReportViewController: BaseViewController<ReportViewModel> {
    // MARK: - Properties
    private var hostingController: UIHostingController<ReportSceneView>?
    
    // MARK: - UIView lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDatasource()
    }
    
    // MARK: - Overriden methods
    override func setupNavBar() {
        super.setupNavBar()
        navigationController?.navigationBar.isHidden = true
    }
}

// MARK: - Private extension
private extension ReportViewController {
    func addHostingController(
        _ controller: UIHostingController<ReportSceneView>
    ) {
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
    
    func updateDatasource() {
        viewModel.$reportScenePropsModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                guard let self = self else {
                    return
                }
                hostingController = UIHostingController(
                    rootView: ReportSceneView(
                        reportScenePropsModel: model,
                        treshold: model.treshold))
                guard let hostingController = hostingController else {
                    return
                }
                addHostingController(hostingController)
            }
            .store(in: &cancellables)
    }
}
