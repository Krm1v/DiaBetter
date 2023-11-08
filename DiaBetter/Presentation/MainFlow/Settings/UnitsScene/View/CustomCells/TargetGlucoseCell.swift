//
//  TargetGlucoseCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 21.06.2023.
//

import UIKit
import Combine
import CombineCocoa

enum TargetGlucoseCellActions {
    case stepperDidTapped(Double)
}

final class TargetGlucoseCell: BaseCollectionViewCell {
    // MARK: - UI Elements
    private lazy var vStack = buildStackView(
        axis: .vertical,
        alignment: .fill,
        distribution: .fillEqually,
        spacing: .zero)
    
    private lazy var titleLabel = buildFieldTitleLabel()
    private lazy var glucoseValueLabel = buildFieldTitleLabel()
    private lazy var stepper = UIStepper()
    
    // MARK: - Properties
    private(set) lazy var actionPublisher = actionSubject.eraseToAnyPublisher()
    private let actionSubject = PassthroughSubject<TargetGlucoseCellActions, Never>()
    
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
    func configure(_ model: TargetGlucoseCellModel) {
        titleLabel.text = model.title
        glucoseValueLabel.text = model.value
        stepper.value = model.stepperValue
        bindActions()
    }
}

// MARK: - Private extension
private extension TargetGlucoseCell {
    func setupUI() {
        [titleLabel, glucoseValueLabel]
            .forEach { $0.font = FontFamily.Montserrat.regular.font(
                size: Constants.defaultFontSize) }
        self.backgroundColor = .black
        rounded(Constants.defaultCornerRadius)
        stepper.backgroundColor = Colors.darkNavyBlue.color
        stepper.maximumValue = Constants.stepperMaxValue
        stepper.minimumValue = Constants.stepperMinValue
        stepper.stepValue = Constants.stepValue
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(
            vStack,
            constraints: [
                vStack.leadingAnchor.constraint(
                    equalTo: self.leadingAnchor,
                    constant: Constants.defaultEdgeInset),
                
                vStack.topAnchor.constraint(
                    equalTo: self.topAnchor,
                    constant: Constants.smallEdgeInset),
                
                vStack.bottomAnchor.constraint(
                    equalTo: self.bottomAnchor,
                    constant: -Constants.smallEdgeInset),
                
                vStack.centerYAnchor.constraint(
                    equalTo: self.centerYAnchor)])
        
        [titleLabel, glucoseValueLabel].forEach { vStack.addArrangedSubview($0) }
        
        addSubview(
            stepper,
            constraints: [
                stepper.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                stepper.trailingAnchor.constraint(
                    equalTo: self.trailingAnchor,
                    constant: -Constants.defaultEdgeInset)
            ])
    }
    
    func bindActions() {
        stepper.valuePublisher
            .sink { [unowned self] value in
                actionSubject.send(.stepperDidTapped(value))
            }
            .store(in: &cancellables)
    }
}

// MARK: - Constants
fileprivate enum Constants {
    static let defaultCornerRadius: CGFloat = 12
    static let stepperMinValue: Double = 2
    static let stepperMaxValue: Double = 500
    static let stepValue: Double = 0.1
    static let defaultEdgeInset: CGFloat = 16
    static let smallEdgeInset: CGFloat = 8
    static let defaultFontSize: CGFloat = 15
}
