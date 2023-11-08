//
//  BackupPlainCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.07.2023.
//

import UIKit

final class BackupPlainCell: BaseCollectionViewCell {
    // MARK: - UI Elements
    private lazy var titleLabel = buildFieldTitleLabel(fontSize: Constants.defaultFontSize)
    
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
    func configure(_ model: BackupShareCellModel) {
        titleLabel.text = model.title
        titleLabel.textColor = model.color.color
    }
}

// MARK: - Private extension
private extension BackupPlainCell {
    func setupUI() {
        self.backgroundColor = .black
        rounded(Constants.defaultCornerRadius)
        titleLabel.font = FontFamily.Montserrat.regular.font(
            size: Constants.defaultFontSize)
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
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultFontSize: CGFloat = 15
    static let defaultEdgeInset: CGFloat = 16
    static let defaultCornerRadius: CGFloat = 12
}
