//
//  LoginSceneViewController.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 24.02.2023.
//

import UIKit
import Combine
import AVFoundation

final class LoginSceneViewController: BaseViewController<LoginSceneViewModel> {
	//MARK: - Properties
	private let contentView = LoginSceneView()
	private var player: AVQueuePlayer?
	private var playerLooper: AVPlayerLooper?
	
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
		setupNavBar()
		playBackgroundVideo()
	}
}

//MARK: - Private extension
private extension LoginSceneViewController {
	func setupNavBar() {
		navigationController?.navigationBar.isHidden = true
	}
	
	func playBackgroundVideo() {
		guard let path = Bundle.main.path(forResource: "loginBackground", ofType: "mp4") else {
			return
		}
//		player = AVPlayer(url: URL(fileURLWithPath: path))
//		let playerLayer = AVPlayerLayer(player: player)
//		playerLayer.frame = self.view.bounds
//		playerLayer.videoGravity = .resizeAspectFill
//		contentView.videoView.layer.addSublayer(playerLayer)
//		player?.play()
		let asset = AVAsset(url: URL(fileURLWithPath: path))
		let item = AVPlayerItem(asset: asset)
		self.player = AVQueuePlayer(playerItem: item)
		self.playerLooper = AVPlayerLooper(player: player!, templateItem: item)
		let playerLayer = AVPlayerLayer(player: player)
		playerLayer.frame = self.view.bounds
		playerLayer.videoGravity = .resizeAspectFill
		contentView.videoContainer.layer.addSublayer(playerLayer)
		player?.play()
	}
	
	func setupBindings() {
		contentView.actionPublisher
			.sink { [unowned self] action in
				switch action {
				case .emailChanged(let text):
					viewModel.email = text
				case .passwordChanged(let text):
					viewModel.password = text
				case .loginTapped:
					viewModel.loginUser()
				case .restorePasswordTapped:
					viewModel.moveToResetPasswordScene()
				case .createAccountTapped:
					viewModel.moveToCreateAccountScene()
				}
			}
			.store(in: &cancellables)
	}
}
