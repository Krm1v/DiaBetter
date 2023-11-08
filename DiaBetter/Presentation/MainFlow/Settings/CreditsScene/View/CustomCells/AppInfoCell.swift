//
//  HeaderCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.06.2023.
//

import UIKit
import Combine

final class AppInfoCell: BaseCollectionViewCell {
    // MARK: - UI Elements
    private lazy var appIconImageView = UIImageView()
    private lazy var appVersionLabel = buildUserInfoLabel()
    private lazy var buildVersionLabel = buildUserInfoLabel()
    private lazy var companyDescriptionLabel = buildUserInfoLabel()
    
    // MARK: - Properties
    
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
    func configure(_ model: AppInfoCellModel) {
        appIconImageView.image = UIImage(data: model.appIcon)
        appVersionLabel.text = model.appVersion
        buildVersionLabel.text = model.buildVersion
        companyDescriptionLabel.text = model.companyInfo
    }
}

// MARK: - Private extension
private extension AppInfoCell {
    func setupUI() {
        self.rounded(Constants.defaultCornerRadius)
        buildVersionLabel.font = FontFamily.Montserrat.regular.font(
            size: Constants.defaultFontSize)
        appIconImageView.rounded(Constants.defaultCornerRadius)
        appIconImageView.layer.borderColor = UIColor.white.cgColor
        appIconImageView.layer.borderWidth = Constants.lineWidth
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(
            appIconImageView,
            constraints: [
                appIconImageView.heightAnchor.constraint(
                    equalToConstant: Constants.imageViewHeightWidthValue),
                
                appIconImageView.widthAnchor.constraint(
                    equalToConstant: Constants.imageViewHeightWidthValue),
                
                appIconImageView.topAnchor.constraint(
                    equalTo: self.topAnchor,
                    constant: Constants.largeEdgeInset),
                
                appIconImageView.centerXAnchor.constraint(
                    equalTo: centerXAnchor)])
        
        addSubview(
            appVersionLabel,
            constraints: [
                appVersionLabel.topAnchor.constraint(
                    equalTo: appIconImageView.bottomAnchor,
                    constant: Constants.defaultEdgeInset),
                
                appVersionLabel.centerXAnchor.constraint(
                    equalTo: centerXAnchor)])
        
        addSubview(
            buildVersionLabel,
            constraints: [
                buildVersionLabel.topAnchor.constraint(
                    equalTo: appVersionLabel.bottomAnchor,
                    constant: Constants.defaultEdgeInset),
                
                buildVersionLabel.centerXAnchor.constraint(
                    equalTo: self.centerXAnchor)])
        
        addSubview(
            companyDescriptionLabel,
            constraints: [
                companyDescriptionLabel.topAnchor.constraint(
                    equalTo: buildVersionLabel.bottomAnchor,
                    constant: Constants.defaultEdgeInset),
                
                companyDescriptionLabel.centerXAnchor.constraint(
                    equalTo: centerXAnchor)])
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultFontSize: CGFloat = 13
    static let defaultCornerRadius: CGFloat = 12
    static let defaultEdgeInset: CGFloat = 8
    static let imageViewHeightWidthValue: CGFloat = 85
    static let largeEdgeInset: CGFloat = 16
    static let lineWidth: CGFloat = 1
}
