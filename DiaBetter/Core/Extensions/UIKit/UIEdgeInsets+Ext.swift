//
//  UIEdgeInsets+Ext.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 12.12.2021.
//

import UIKit

extension UIEdgeInsets {
    static func all(_ value: CGFloat) -> UIEdgeInsets {
        return .init(
            top: value,
            left: value,
            bottom: value,
            right: value)
    }
}
