//
//  AppleHealthActivationCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 06.07.2023.
//

import UIKit
import Combine

final class AppleHealthActivationCell: BaseCollectionViewCell {
    // MARK: - UI Elements
    private lazy var titleLabel = buildFieldTitleLabel(fontSize: Constants.defaultFontSize)
    private lazy var healthSwitch = UISwitch()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Public methods
    func configure(_ model: AppleHealthCellModel) {
        titleLabel.text = model.title
        healthSwitch.isOn = model.isConnected
    }
}

// MARK: - Private extension
private extension AppleHealthActivationCell {
    func setupUI() {
        self.backgroundColor = .black
        rounded(Constants.defaultCornerRadius)
        titleLabel.font = FontFamily.Montserrat.regular.font(
            size: Constants.defaultFontSize)
        healthSwitch.onTintColor = Colors.customPink.color
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(
            titleLabel,
            constraints: [
                titleLabel.leadingAnchor.constraint(
                    equalTo: self.leadingAnchor,
                    constant: Constants.defaultEdgeInset),
                
                titleLabel.centerYAnchor.constraint(
                    equalTo: self.centerYAnchor)])
        
        addSubview(
            healthSwitch,
            constraints: [
                healthSwitch.trailingAnchor.constraint(
                    equalTo: self.trailingAnchor,
                    constant: -Constants.defaultEdgeInset),
                
                healthSwitch.centerYAnchor.constraint(
                    equalTo: self.centerYAnchor)])
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultFontSize: CGFloat = 15
    static let defaultCornerRadius: CGFloat = 12
    static let defaultEdgeInset: CGFloat = 16
}
