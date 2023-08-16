//
//  SwiftUICanvas.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.04.2023.
//

import SwiftUI

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
	let viewController: ViewController
	
	init(_ builder: @escaping () -> ViewController) {
		viewController = builder()
	}
	
	// MARK: - UIViewControllerRepresentable
	func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
	
	func makeUIViewController(context: Context) -> ViewController {
		viewController
	}
}
