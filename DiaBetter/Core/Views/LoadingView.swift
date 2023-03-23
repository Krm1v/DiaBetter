//
//  LoadingView.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 12.12.2021.
//

import UIKit

final class LoadingView: UIView {
	//MARK: - Properties
	static let tagValue: Int = 1234123
	
	var isLoading: Bool = false {
		didSet { isLoading ? start() : stop() }
	}
	private let indicator = UIActivityIndicatorView(style: .large)
	
	//MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		initialSetup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: - Public methods
	func start() {
		indicator.startAnimating()
	}

	func stop() {
		indicator.stopAnimating()
	}
}

//MARK: - Private extension
private extension LoadingView {
	func initialSetup() {
        tag = LoadingView.tagValue
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
