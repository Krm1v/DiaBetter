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
	private let notificationCenter = NotificationCenter.default
	private var player: AVQueuePlayer?
	private var playerLooper: AVPlayerLooper?
	
	//MARK: - UIView lifecycle methods
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupBindings()
		addObservers()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			guard let self = self else { return }
			self.playBackgroundVideo()
		}
	}
	
	//MARK: - Deinit
	deinit {
		removeObservers()
	}
}

//MARK: - Private extension
private extension LoginSceneViewController {
	//MARK: - AVPlayer
	func playBackgroundVideo() {
		guard let path = Bundle.main.path(forResource: Files.loginBackgroundMp4.name,
										  ofType: Files.loginBackgroundMp4.ext) else {
			return
		}
		let asset = AVAsset(url: URL(fileURLWithPath: path))
		let item = AVPlayerItem(asset: asset)
		self.player = AVQueuePlayer(playerItem: item)
		if let player = self.player {
			self.playerLooper = AVPlayerLooper(player: player, templateItem: item)
		}
		let playerLayer = AVPlayerLayer(player: player)
		playerLayer.frame = self.view.bounds
		playerLayer.videoGravity = .resizeAspectFill
		contentView.videoContainer.layer.addSublayer(playerLayer)
		player?.play()
	}
	
	//MARK: - NotificationCenter
	func addObservers() {
		notificationCenter.publisher(for: UIApplication.willResignActiveNotification,
									 object: nil)
		.sink { [weak self] _ in
			guard let self = self else { return }
			self.willResignActive()
		}
		.store(in: &cancellables)
		
		notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification,
									 object: nil)
		.sink { [weak self] _ in
			guard let self = self else { return }
			self.didBecomeActive()
		}
		.store(in: &cancellables)
	}
	
	func removeObservers() {
		notificationCenter.removeObserver(self,
										  name: UIApplication.willResignActiveNotification,
										  object: nil
		)
		
		notificationCenter.removeObserver(self,
										  name: UIApplication.didBecomeActiveNotification,
										  object: nil
		)
	}
	
	func willResignActive() {
		if let player = player, player.isPlaying {
			player.pause()
		}
	}
	
	func didBecomeActive() {
		if let player = player, !player.isPlaying {
			player.play()
		}
	}
	
	//MARK: - Bind actions
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
