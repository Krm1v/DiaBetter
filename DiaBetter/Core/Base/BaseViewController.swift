//
//  BaseViewController.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 24.10.2021.
//

import UIKit
import Combine
import CombineCocoa
import KeyboardLayoutGuide

class BaseViewController<VM: ViewModel>: UIViewController {
	//MARK: - Properties
	var viewModel: VM
	var cancellables = Set<AnyCancellable>()
	
	//MARK: - Init
	init(viewModel: VM) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: - UIView lifecycle methods
	override func viewDidLoad() {
		super.viewDidLoad()
		viewModel.onViewDidLoad()
		
		viewModel.isLoadingPublisher
			.sink { [weak self] isLoading in
				isLoading ? self?.showLoadingView() : self?.hideLoadingView()
			}
			.store(in: &cancellables)
		
		viewModel.errorPublisher
			.sink { [weak self] error in
				let alertController = UIAlertController(title: Localization.error, message: error.localizedDescription, preferredStyle: .alert)
				let okAction = UIAlertAction(title: Localization.ok, style: .default, handler: nil)
				alertController.addAction(okAction)
				self?.present(alertController, animated: true, completion: nil)
			}
			.store(in: &cancellables)
		viewModel.infoPublisher
			.sink { [weak self] (title, info) in
				let alertController = UIAlertController(title: title, message: info, preferredStyle: .alert)
				let okAction = UIAlertAction(title: Localization.ok, style: .default)
				alertController.addAction(okAction)
				self?.present(alertController, animated: true)
			}
			.store(in: &cancellables)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.onViewWillAppear()
		setupNavBar()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		viewModel.onViewDidAppear()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel.onViewWillDisappear()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		viewModel.onViewDidDisappear()
	}
	
	//MARK: - Public methods
	func showLoadingView() {
		let windowView = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
		if let loadingView = windowView?.viewWithTag(LoadingView.tagValue) as? LoadingView {
			loadingView.isLoading = true
		} else {
			let loadingView = LoadingView(frame: UIScreen.main.bounds)
			windowView?.addSubview(loadingView)
			loadingView.isLoading = true
		}
	}
	
	func hideLoadingView() {
		let windowView = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
		windowView?.viewWithTag(LoadingView.tagValue)?.removeFromSuperview()
	}
	
	//MARK: - Deinit
	deinit {
		debugPrint("deinit of ", String(describing: self))
	}
}

//MARK: - Private extension
private extension BaseViewController {
	func setupNavBar() {
		navigationController?.navigationBar.largeTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: Colors.customPink.color,
			NSAttributedString.Key.font: FontFamily.Montserrat.bold.font(size: 30)
		]
		let appearance = UINavigationBarAppearance()
		let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
		buttonAppearance.normal.titleTextAttributes = [.foregroundColor: Colors.customPink.color]
		appearance.buttonAppearance = buttonAppearance
		UINavigationBar.appearance().tintColor = Colors.customPink.color
	}
}
