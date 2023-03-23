//
//  ViewRepresentable.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 14.11.2021.
//

import SwiftUI
import UIKit

struct ViewRepresentable<View: UIView>: UIViewRepresentable {
	//MARK: - Propertirs
    let view: View
    
	//MARK: - Init
    init(_ view: View, setup: (View) -> Void = { _ in }) {
        self.view = view
        setup(view)
    }
    
	//MARK: - Public methods
    func makeUIView(context: Context) -> View {
        view
    }
    
    func updateUIView(_ uiView: View, context: Context) { }
}
