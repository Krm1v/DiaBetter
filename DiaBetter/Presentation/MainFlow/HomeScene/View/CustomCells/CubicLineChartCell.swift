//
//  BubbleChartCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 10.05.2023.
//

import UIKit
import Combine
import Charts

final class CubicLineChartCell: BaseWidgetCell {
	//MARK: - Properties
	private let allFilters = WidgetFilterState.allCases
	
	//MARK: - UI Elements
	private lazy var chartView = LineChartView()
	
	//MARK: - Init
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
	
	//MARK: - Public methods
	func configure(with model: GlucoseLevelPerPeriodWidgetModel) {
		let entries = model.items.map { ChartDataEntry(x: $0.x, y: $0.y) }
		segmentedControl.selectedSegmentIndex = model.filter.rawValue
		setData(entries)
	}
}

//MARK: - Private extension
private extension CubicLineChartCell {
	func setupUI() {
	   titleLabel.text = Localization.glucose
	   substrateView.addSubview(chartView, withEdgeInsets: .all(.zero))
	   for filter in allFilters {
		   segmentedControl.insertSegment(withTitle: filter.title,
										  at: filter.rawValue,
										  animated: false)
	   }
   }
	
	func configureChartView() {
		chartView.delegate = self
		chartView.backgroundColor = Colors.darkNavyBlue.color
		chartView.dragEnabled = true
		chartView.setScaleEnabled(false)
		chartView.pinchZoomEnabled = false
		chartView.highlightPerDragEnabled = true
		chartView.rightAxis.enabled = false
		chartView.legend.enabled = false
		chartView.clipDataToContentEnabled = false
		chartView.setScaleMinima(Constants.minimumScale, scaleY: .zero)
		
		let xAxis = chartView.xAxis
		xAxis.valueFormatter = ChartsDateFormatter(format: .day)
		xAxis.labelPosition = .top
		xAxis.labelFont = FontFamily.Montserrat.regular.font(size: Constants.defaultFontSize)
		xAxis.labelTextColor = .white
		xAxis.avoidFirstLastClippingEnabled = true
		xAxis.drawAxisLineEnabled = true
		xAxis.drawGridLinesEnabled = true
		xAxis.centerAxisLabelsEnabled = false
		xAxis.granularityEnabled = true
		xAxis.granularity = Constants.defaultGranularity
		xAxis.axisLineColor = Colors.customDarkenPink.color
		xAxis.setLabelCount(Constants.defaultxAxisLabelCount, force: true)
		
		let yAxis = chartView.leftAxis
		yAxis.labelFont = FontFamily.Montserrat.regular.font(size: Constants.defaultFontSize)
		yAxis.labelTextColor = .white
		yAxis.axisLineColor = .white
		yAxis.labelPosition = .outsideChart
		yAxis.axisMinimum = Constants.yAxisMin
		yAxis.axisMaximum = Constants.yAxisMax
		yAxis.setLabelCount(Constants.defaultyAxisLabelCount, force: false)
	}
	
	func setData(_ entries: [ChartDataEntry]) {
		let glucoseSet = LineChartDataSet(entries: entries)
		glucoseSet.colors = [Colors.customPink.color]
		glucoseSet.mode = .cubicBezier
		glucoseSet.drawCirclesEnabled = false
		glucoseSet.cubicIntensity = Constants.defaultCubicIntensity
		glucoseSet.lineWidth = Constants.defaultLineWidth
		glucoseSet.circleRadius = Constants.defaultCircleRadius
		glucoseSet.setCircleColor(.white)
		glucoseSet.fillColor = .white
		glucoseSet.fillAlpha = Constants.defaultFillAlpha
		glucoseSet.drawHorizontalHighlightIndicatorEnabled = false
		glucoseSet.axisDependency = .left
		let data = LineChartData(dataSet: glucoseSet)
		chartView.moveViewToX(data.xMax)
		chartView.animate(xAxisDuration: Constants.defaultAnimationDuration,
						  yAxisDuration: Constants.defaultAnimationDuration)
		chartView.data = data
	}
}

//MARK: - Extension ChartViewDelegate
extension CubicLineChartCell: ChartViewDelegate {
	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
		debugPrint(entry)
	}
}

//MARK: - Constants
fileprivate enum Constants {
	static let defaultAnimationDuration: TimeInterval = 1
	static let minimumScale: 		   	 Double = 8
	static let defaultxAxisLabelCount: 	 Int = 4
	static let defaultGranularity: 	   	 Double = 86400
	static let yAxisMin: 			   	 Double = 2
	static let yAxisMax: 			   	 Double = 32
	static let defaultyAxisLabelCount: 	 Int = 6
	static let defaultFontSize: 	   	 CGFloat = 12
	static let defaultCornerRadius:    	 CGFloat = 12
	static let defaultMinInset: 	   	 CGFloat = 8
	static let defaultLineWidth: 	   	 CGFloat = 1.8
	static let defaultCircleRadius:    	 CGFloat = 4
	static let defaultCubicIntensity:  	 CGFloat = 0.05
	static let defaultFillAlpha: 	   	 CGFloat = 1
}
