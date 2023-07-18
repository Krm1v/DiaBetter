//
//  BaseView.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 12.12.2021.
//

import UIKit
import Combine
import CombineCocoa

class BaseView: UIView {
	//MARK: - Properties
    var cancellables = Set<AnyCancellable>()
}

//MARK: - Extension UIElementsBuilder
extension BaseView: UIElementsBuilder { }
