//
//  UserSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.02.2023.
//

import UIKit
import Combine

final class UserSceneViewController: BaseViewController<UserSceneViewModel> {
    // MARK: - Properties
    private let contentView = UserSceneView()
    
    // MARK: - UIView lifecycle methods
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        setupActions()
        super.viewDidLoad()
        setupPermissions()
        didUpdatedUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDiffableDatasourceSnapshot()
    }
    
    // MARK: - Overriden methods
    override func setupNavBar() {
        super.setupNavBar()
        title = Localization.userProfile
        navigationItem.largeTitleDisplayMode = .never
        contentView.setupSaveButton(for: self)
    }
}

// MARK: - Private extension
private extension UserSceneViewController {
    // MARK: - Datasource and bindings
    func updateDiffableDatasourceSnapshot() {
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] sections in
                self.contentView.setupSnapshot(sections: sections)
            }
            .store(in: &cancellables)
    }
    
    func setupActions() {
        contentView.actionPublisher
            .sink { [weak self] action in
                guard let self = self else {
                    return
                }
                switch action {
                case .destrucriveButtonDidTapped(let buttonModel):
                    switch buttonModel.buttonType {
                    case .logout:
                        self.viewModel.logout()
                    case .deleteAccount:
                        self.showAlert(
                            alertTitle: Localization.deleteAccountAlert,
                            alertMessage: Localization.deleteAccountAlertMessage,
                            confirmActionTitle: Localization.yes
                        ) { [weak self] in
                            guard let self = self else {
                                return
                            }
                            viewModel.deleteAccount()
                        }
                    }
                    
                case .editButtonTapped:
                    self.presentActionSheet()
                    
                case .userDataTextfieldDidChanged(let text):
                    self.viewModel.userName = text
                    
                case .popoverListDidTapped(let setting):
                    switch setting.source {
                    case .diabetesType:
                        self.viewModel.userDiabetesType = setting.labelValue
                        
                    case .fastInsulin:
                        self.viewModel.userFastInsulin = setting.labelValue
                        
                    case .longInsulin:
                        self.viewModel.userBasalInsulin = setting.labelValue
                    }
                    
                case .saveButtonDidTapped:
                    viewModel.saveUserProfileData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Photo library permissions
    func setupPermissions() {
        viewModel.permissionService.photoPermissonPublisher
            .sink { [unowned self] status in
                switch status {
                case .authorized:
                    presentImagePickerController()
                case .denied, .limited, .notDetermined, .restricted:
                    showAlert(
                        alertTitle: Localization.accessDenied,
                        alertMessage: Localization.photoLibraryPermissionsMessage,
                        confirmActionTitle: Localization.goToSettings
                    ) { [weak self] in
                        guard let self = self else {
                            return
                        }
                        UIApplication.shared.openSettings()
                    }
                @unknown default: break
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Presentable elements
    func presentActionSheet() {
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        
        let changePhotoAction = UIAlertAction(
            title: Localization.changePhoto,
            style: .default
        ) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.viewModel.askForPhotoPermissions()
        }
        let deleteAction = UIAlertAction(
            title: Localization.deletePhoto,
            style: .destructive
        ) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.viewModel.deleteImage()
        }
        let cancelAction = UIAlertAction(
            title: Localization.cancel,
            style: .cancel)
        
        [changePhotoAction, deleteAction, cancelAction].forEach { action in
            alertController.addAction(action)
        }
        present(alertController, animated: true)
    }
    
    func presentImagePickerController() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func showAlert(
        alertTitle: String,
        alertMessage: String,
        confirmActionTitle: String,
        completion: @escaping () -> Void
    ) {
        let alertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert)
        
        let goToSettingsAction = UIAlertAction(
            title: confirmActionTitle,
            style: .default
        ) { _ in
            completion()
        }
        
        let cancelAction = UIAlertAction(
            title: Localization.cancel,
            style: .cancel)
        
        alertController.addAction(goToSettingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func didUpdatedUser() {
        viewModel.$userDidUpdated
            .sink { [weak self] didUpdated in
                guard let self = self else {
                    return
                }
                self.navigationItem.rightBarButtonItem?.isEnabled = didUpdated ? true : false
            }
            .store(in: &cancellables)
    }
}

// MARK: - Extension UIImagePickerControllerDelegate
extension UserSceneViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        guard let dataImage = image.pngData() else {
            return
        }
        viewModel.fetchImageData(from: dataImage)
        viewModel.uploadImage()
        dismiss(animated: true)
    }
}
