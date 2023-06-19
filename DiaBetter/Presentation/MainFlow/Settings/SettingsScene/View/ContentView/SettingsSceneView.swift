//
//  SettingsSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.03.2023.
//

import UIKit
import Combine

enum SettingsSceneActions {
	case cellTapped(Settings)
}

final class SettingsSceneView: BaseView {
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<SettingsSceneActions, Never>()
	
	//MARK: - UI Elements
	private let tableView = SettingsTableView(frame: .zero, style: .insetGrouped)
	
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
}

//MARK: - Private extension
private extension SettingsSceneView {
	func setupUI() {
		backgroundColor = .black
		addSubview(tableView, withEdgeInsets: .all(.zero))
	}
	
	//MARK: - Actions
	func bindActions() {
		tableView.didSelectRowPublisher
			.sink { [unowned self] indexPath in
				guard let object = tableView.getObject(with: indexPath) else {
					return
				}
				actionSubject.send(.cellTapped(object))
			}
			.store(in: &cancellables)
	}
}

//MARK: - SwiftUI preview
#if DEBUG
import SwiftUI
struct SettingsScenePreview: PreviewProvider {
	static var previews: some View {
		ViewRepresentable(SettingsSceneView())
	}
}
#endif
