//
//  UserSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 17.02.2023.
//

import UIKit
import Combine

final class UserSceneViewController: BaseViewController<UserSceneViewModel> {
	//MARK: - Properties
	private let contentView = UserSceneView()
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupActions()
		setupPermissions()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateDiffableDatasourceSnapshot()
	}
	
	//MARK: - Overriden methods
	override func setupNavBar() {
		super.setupNavBar()
		title = Localization.userProfile
		navigationItem.largeTitleDisplayMode = .never
	}
}

//MARK: - Private extension
private extension UserSceneViewController {
	//MARK: - Datasource and bindings
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
				guard let self = self else { return }
				switch action {
				case .logoutButtonTapped:
					self.viewModel.logoutUser()
					
				case .editButtonTapped:
					self.presentActionSheet()
					
				case .userDataTextfieldDidChanged(let text):
					self.viewModel.userName = text
					
				case .popoverListDidTapped(let setting):
					switch setting.source {
					case .diabetesType:
						self.viewModel.userDiabetesType = setting.labelValue
					case .fastInsulines:
						self.viewModel.userFastInsulin = setting.labelValue
					case .longInsulines:
						self.viewModel.userBasalInsulin = setting.labelValue
					}
				}
			}
			.store(in: &cancellables)
	}
	
	//MARK: - Photo library permissions
	func setupPermissions() {
		viewModel.permissionService.photoPermissonPublisher
			.sink { [unowned self] status in
				switch status {
				case .authorized:
					presentImagePickerController()
				case .denied, .limited, .notDetermined, .restricted:
					showAccessDeniedAlert()
				@unknown default:
					break
				}
			}
			.store(in: &cancellables)
	}
	
	//MARK: - Presentable elements
	func presentActionSheet() {
		let alertController = UIAlertController(title: nil,
												message: nil,
												preferredStyle: .actionSheet)
		let changePhotoAction = UIAlertAction(title: Localization.changePhoto, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.viewModel.askForPermissions()
		}
		let deleteAction = UIAlertAction(title: Localization.deletePhoto, style: .destructive) { [weak self] _ in
			guard let self = self else { return }
			self.viewModel.deleteUserProfilePhoto()
		}
		let cancelAction = UIAlertAction(title: Localization.cancel, style: .cancel)
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
	
	func showAccessDeniedAlert() {
		let alertController = UIAlertController(title: Localization.accessDenied,
												message: Localization.photoLibraryPermissionsMessage,
												preferredStyle: .alert)
		let goToSettingsAction = UIAlertAction(title: Localization.goToSettings, style: .default) { _ in
			UIApplication.shared.openSettings()
		}
		let cancelAction = UIAlertAction(title: Localization.cancel, style: .cancel)
		alertController.addAction(goToSettingsAction); alertController.addAction(cancelAction)
		present(alertController, animated: true)
	}
}

//MARK: - Extension UIImagePickerControllerDelegate
extension UserSceneViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController,
							   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		guard let image = info[.editedImage] as? UIImage else {
			return
		}
		guard let dataImage = image.pngData() else {
			return
		}
		viewModel.fetchImageData(from: dataImage)
		viewModel.uploadUserProfileImage()
		dismiss(animated: true)
	}
}
