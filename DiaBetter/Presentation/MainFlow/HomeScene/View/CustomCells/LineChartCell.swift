//
//  LineChartCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 09.05.2023.
//

import UIKit
import Combine
import Charts

enum LineChartCellAction {
	case didSelectState(LineChartState)
}

final class LineChartCell: BaseWidgetCell {
	// MARK: - Properties
	private(set) lazy var lineChartCellPublisher = lineChartCellSubject.eraseToAnyPublisher()
	private let lineChartCellSubject = PassthroughSubject<LineChartCellAction, Never>()
	private let allStates = LineChartState.allCases

	// MARK: - UI Elements
	private lazy var chartView = ScatterChartView()

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupUI()
		configureChartView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupUI()
		configureChartView()
	}

	// MARK: - Public methods
	func configure(with model: LineChartCellModel) {
		setupBindings()
		let chartsEntries = model.items.map { $0.entry }
		titleLabel.text = model.state.title
		segmentedControl.selectedSegmentIndex = model.state.rawValue
		setData(chartsEntries)
	}
}

// MARK: - Private extension
private extension LineChartCell {
	func setupUI() {
		substrateView.addSubview(chartView, withEdgeInsets: .all(.zero))
		for state in allStates {
			segmentedControl.insertSegment(with: UIImage(systemName: state.imageName),
										   at: state.rawValue,
										   animated: false)
		}
	}

	func configureChartView() {
		chartView.backgroundColor = Colors.darkNavyBlue.color
		chartView.delegate = self
		chartView.chartDescription.enabled = false
		chartView.dragEnabled = true
		chartView.setScaleEnabled(false)
		chartView.pinchZoomEnabled = false
		chartView.highlightPerDragEnabled = true
		chartView.legend.enabled = false
		chartView.rightAxis.enabled = false
		chartView.clipDataToContentEnabled = false
		chartView.setScaleMinima(Constants.minScale, scaleY: .zero)

		let xAxis = chartView.xAxis
		xAxis.labelPosition = .top
		xAxis.labelFont = FontFamily.SFProRounded.regular.font(size: Constants.defaultMediumFontSize)
		xAxis.labelTextColor = .white
		xAxis.avoidFirstLastClippingEnabled = true
		xAxis.drawAxisLineEnabled = true
		xAxis.drawGridLinesEnabled = true
		xAxis.centerAxisLabelsEnabled = false
		xAxis.granularityEnabled = true
		xAxis.granularity = Constants.defaultGranularity
		xAxis.valueFormatter = ChartsDateFormatter(format: .dayTime)
		xAxis.axisLineColor = Colors.customDarkenPink.color
		xAxis.setLabelCount(Constants.labelCount, force: true)

		let leftAxis = chartView.leftAxis
		leftAxis.labelPosition = .outsideChart
		leftAxis.labelFont = FontFamily.SFProRounded.regular.font(size: Constants.defaultLargeFontSize)
		leftAxis.drawGridLinesEnabled = true
		leftAxis.granularityEnabled = true
		leftAxis.axisMinimum = Constants.leftAxisMin
		leftAxis.axisMaximum = Constants.leftAxisMax
		leftAxis.axisLineColor = Colors.customDarkenPink.color
	}

	func setData(_ entries: [ChartDataEntry]) {
		let dataSet = ScatterChartDataSet(entries: entries)
		dataSet.setScatterShape(.circle)
		dataSet.colors = [Colors.customPink.color]
		dataSet.axisDependency = .left
		dataSet.valueTextColor = .white
		dataSet.drawValuesEnabled = false
		let data = ScatterChartData(dataSet: dataSet)
		data.setValueFont(FontFamily.SFProRounded.regular.font(size: Constants.defaultSmallFontSize))
		data.setDrawValues(true)
		chartView.moveViewToX(data.xMax)
		chartView.data = data
		chartView.animate(xAxisDuration: Constants.defaultAnimationLenght,
						  yAxisDuration: Constants.defaultAnimationLenght)
	}

	func setupBindings() {
		segmentedControl.selectedSegmentIndexPublisher
			.compactMap { LineChartState(rawValue: $0) }
			.map { LineChartCellAction.didSelectState($0) }
			.subscribe(lineChartCellSubject)
			.store(in: &cancellables)
	}
}

// MARK: - Extension ChartViewDelegate
extension LineChartCell: ChartViewDelegate {
	func chartValueSelected(
		_ chartView: ChartViewBase,
		entry: ChartDataEntry,
		highlight: Highlight
	) {
		debugPrint(entry)
	}
}

// MARK: - Constants
private enum Constants {
	static let labelCount: 	   		   Int = 3
	static let defaultAnimationLenght: TimeInterval = 1
	static let defaultGranularity: 	   Double = 86400
	static let minScale: 			   Double = 10
	static let leftAxisMin: 		   Double = 2
	static let leftAxisMax: 		   Double = 32
	static let defaultSmallFontSize:   CGFloat = 9
	static let defaultMediumFontSize:  CGFloat = 10
	static let defaultLargeFontSize:   CGFloat = 12
}
