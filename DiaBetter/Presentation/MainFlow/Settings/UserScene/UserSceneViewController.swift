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
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupUI()
		setupNavBar()
	}
}

//MARK: - Private extension
private extension UserSceneViewController {
	func setupUI() {
		viewModel.$sections
			.receive(on: DispatchQueue.main)
			.sink { [unowned self] sections in
				self.contentView.setupSnapshot(sections: sections)
			}
			.store(in: &cancellables)
	}
	
	func setupNavBar() {
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .never
		navigationItem.backBarButtonItem?.tintColor = .black
		title = Localization.userProfile
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
				}
			}
			.store(in: &cancellables)
	}
	
	func presentActionSheet() {
		let alertController = UIAlertController(title: nil,
												message: nil,
												preferredStyle: .actionSheet)
		let changePhotoAction = UIAlertAction(title: Localization.changePhoto, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.presentImagePickerController()
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
		picker.delegate = self
		present(picker, animated: true)
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
		viewModel.saveUserImageData(from: dataImage)
		dismiss(animated: true)
		viewModel.uploadUserProfileImage()
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let basicCompressionQuality: CGFloat = 1
}
