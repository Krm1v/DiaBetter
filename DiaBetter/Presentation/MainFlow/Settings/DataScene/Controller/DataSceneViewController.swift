//
//  DataSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.07.2023.
//

import UIKit
import Combine

final class DataSceneViewConroller: BaseViewController<DataSceneViewModel> {
    // MARK: - Properties
    private let contentView = DataSceneView()
    
    // MARK: - UIView lifecycle methods
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDatasourceSnapshot()
    }
    
    // MARK: - Overriden methods
    override func setupNavBar() {
        super.setupNavBar()
        title = Localization.data
    }
}

// MARK: - Private extension
private extension DataSceneViewConroller {
    func setupDatasourceSnapshot() {
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
                case .backupDidTapped(let model):
                    switch model.item {
                    case .backup:
                        self.viewModel.openBackupScene()
                        
                    case .importItem:
                        presentDocumentPickerController()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func presentDocumentPickerController() {
        let uiDocumentController = UIDocumentPickerViewController(
            forOpeningContentTypes: [.json])
        
        uiDocumentController.delegate = self
        present(uiDocumentController, animated: true, completion: nil)
        
    }
}

// MARK: - Extension UIDocumentPickerDelegate
extension DataSceneViewConroller: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        viewModel.inputURL = urls.last
        viewModel.importBackup()
    }
}
