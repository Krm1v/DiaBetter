//
//  UIStackView+Ext.swift
//  MVVMSkeleton
//
//  Created by Roman Savchenko on 28.11.2021.
//

import UIKit

extension UIStackView {
    // MARK: - StackView setup
    func setup(
        axis: NSLayoutConstraint.Axis = .vertical,
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        spacing: CGFloat = .zero
    ) {
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }
    
    // MARK: - Remove subviews
    func removeAllViews() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    // MARK: - Add spacer
    func addSpacer(_ size: CGFloat? = nil) {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        addArranged(spacer, size: size)
    }
    
    // MARK: - Add arranged
    func addArranged(
        _ view: UIView,
        size: CGFloat? = nil
    ) {
        addArrangedSubview(view)
        guard let size = size else {
            return
        }
        switch axis {
        case .vertical:
            view.heightAnchor.constraint(equalToConstant: size).isActive = true
        case .horizontal:
            view.widthAnchor.constraint(equalToConstant: size).isActive = true
        default: return
        }
    }
    
    // MARK: - Add centered
    func addCentered(
        _ view: UIView,
        inset: CGFloat,
        size: CGFloat? = nil
    ) {
        let stack = UIStackView()
        switch axis {
        case .vertical:
            stack.setup(
                axis: .horizontal,
                alignment: .fill,
                distribution: .fill,
                spacing: 0)
        case .horizontal:
            stack.setup(
                axis: .vertical,
                alignment: .fill,
                distribution: .fill,
                spacing: 0)
        default: return
        }
        stack.addSpacer(inset)
        stack.addArranged(view)
        stack.addSpacer(inset)
        addArranged(stack, size: size)
    }
}
