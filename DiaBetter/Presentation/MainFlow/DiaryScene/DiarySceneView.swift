//
//  MeasurementsSceneView.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 20.02.2023.
//

import UIKit
import Combine

enum DiarySceneViewActions {
	
}

final class DiarySceneView: BaseView {
	//MARK: - Properties
	private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
	private let actionSubject = PassthroughSubject<DiarySceneViewActions, Never>()
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
	}
}

//MARK: - Private extension
private extension DiarySceneView {
	func setupUI() {
		backgroundColor = .white
	}
}

//MARK: - SwiftUI preview
#if DEBUG
import SwiftUI
struct MeasurementsScenePreview: PreviewProvider {
	static var previews: some View {
		ViewRepresentable(DiarySceneView())
	}
}
#endif
