//
//  HomeSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 04.03.2023.
//

import UIKit
import Combine

enum HomeSceneActions {
	case settingsButtonTapped
}

final class HomeSceneView: BaseView {
	//MARK: - Propertirs
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<HomeSceneActions, Never>()
	
	//MARK: - UIElements
	private lazy var addNewRecordButton = buildNavBarButton()
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		bindActions()
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		bindActions()
		setupUI()
	}
	
	//MARK: - Public methods
	func setupSettingsButton(for controller: UIViewController) {
		addNewRecordButton.style = .plain
		addNewRecordButton.image = .add
		addNewRecordButton.tintColor = Colors.customPink.color
		controller.navigationItem.rightBarButtonItem = addNewRecordButton
	}
}

//MARK: - Private extension
private extension HomeSceneView {
	func setupUI() {
		backgroundColor = .black
	}
	
	//MARK: - Actions binding
	func bindActions() {
		addNewRecordButton.tapPublisher
			.sink { [unowned self] in
				actionSubject.send(.settingsButtonTapped)
			}
			.store(in: &cancellables)
	}
}
