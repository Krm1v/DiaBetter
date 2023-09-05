//
//  InsulinUsageChartCell.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 15.05.2023.
//

import UIKit
import Charts

final class InsulinUsageChartCell: BaseWidgetCell {
	// MARK: - Properties
	private var allFilters = WidgetFilterState.allCases

	// MARK: - UI Elements
	private lazy var chartView = LineChartView()

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
	func configure(with model: InsulinUsageChartModel) {
		let fastInsulinEntries = model.fastInsulin.map { ChartDataEntry(x: $0.xValue,
																		y: $0.yValue) }
		let basalInsulinEntries = model.basalInsulin.map { ChartDataEntry(x: $0.xValue,
																		  y: $0.yValue) }
		segmentedControl.selectedSegmentIndex = model.filter.rawValue
		setData(fastInsulinEntries, basalInsulinEntries)
	}
}

// MARK: - Private extension
private extension InsulinUsageChartCell {
	func setupUI() {
		titleLabel.text = Localization.insulinUsage
		substrateView.addSubview(chartView, withEdgeInsets: .all(.zero))
		for filter in allFilters {
			segmentedControl.insertSegment(withTitle: filter.title,
										   at: filter.rawValue,
										   animated: false)
		}
	}

	func configureChartView() {
		chartView.delegate = self
		chartView.chartDescription.enabled = false
		chartView.dragEnabled = true
		chartView.setScaleEnabled(false)
		chartView.pinchZoomEnabled = false
		chartView.legend.verticalAlignment = .top
		chartView.legend.orientation = .horizontal
		chartView.legend.drawInside = false
		chartView.legend.font = FontFamily.Montserrat.regular.font(size: Constants.basicMediumFontSize)
		chartView.legend.yOffset = Constants.basicLegendOffset
		chartView.leftAxis.labelFont = FontFamily.Montserrat.regular.font(size: Constants.basicMediumFontSize)
		chartView.leftAxis.spaceTop = Constants.basicLeftAxisSpacing
		chartView.leftAxis.spaceBottom = Constants.basicLeftAxisSpacing
		chartView.leftAxis.axisMinimum = Constants.leftAxisMin
		chartView.leftAxis.axisMaximum = Constants.leftAxisMax
		chartView.rightAxis.enabled = true
		chartView.leftAxis.enabled = false
		chartView.xAxis.labelPosition = .top
		chartView.xAxis.granularityEnabled = true
		chartView.xAxis.granularity = Constants.basicXAxisGranularity
		chartView.xAxis.labelFont = FontFamily.Montserrat.regular.font(size: Constants.basicMediumFontSize)
		chartView.xAxis.valueFormatter = ChartsDateFormatter(format: .day)
		chartView.xAxis.setLabelCount(Constants.xAxisLabelCount, force: true)
		chartView.setScaleMinima(Constants.minScale, scaleY: .zero)
	}

	func setData(
		_ fastInsulinEntries: [ChartDataEntry],
		_ longInsulinEntries: [ChartDataEntry]
	) {
		let fastInsulinSet = LineChartDataSet(entries: fastInsulinEntries, label: Localization.fastActingInsulin)
		fastInsulinSet.setColor(Colors.customLightBlue.color, alpha: Constants.defaultAlpha)
		fastInsulinSet.mode = .horizontalBezier
		fastInsulinSet.setCircleColor(Colors.customLightBlue.color)
		fastInsulinSet.circleHoleColor = Colors.customDarkenPink.color
		let basalInsulinSet = LineChartDataSet(entries: longInsulinEntries, label: Localization.basalInsulin)
		basalInsulinSet.setColor(Colors.customLightYellow.color, alpha: Constants.defaultAlpha)
		basalInsulinSet.mode = .stepped
		basalInsulinSet.setCircleColor(Colors.customLightYellow.color)
		basalInsulinSet.circleHoleColor = Colors.customDarkenPink.color

		[fastInsulinSet, basalInsulinSet].forEach {
			$0.drawIconsEnabled = false
			$0.form = .circle
			$0.drawValuesEnabled = true
		}
		let dataSets: [LineChartDataSet] = [fastInsulinSet, basalInsulinSet]
		let data = LineChartData(dataSets: dataSets)
		data.setValueFont(FontFamily.Montserrat.regular.font(size: Constants.basicMinFontSize))
		data.setValueTextColor(.white)
		data.setDrawValues(true)
		chartView.data = data
		chartView.moveViewToX(data.xMax)
		chartView.animate(xAxisDuration: Constants.basicAnimationDuration,
						  yAxisDuration: Constants.basicAnimationDuration)
	}
}

// MARK: - Extension ChartViewDelegate
extension InsulinUsageChartCell: ChartViewDelegate {
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
	static let basicCornerRadius: 	   CGFloat = 12
	static let basicLegendOffset: 	   CGFloat = 10
	static let basicMediumFontSize:    CGFloat = 10
	static let basicMinFontSize: 	   CGFloat = 7
	static let basicLeftAxisSpacing:   CGFloat = 0.3
	static let defaultAlpha: 		   CGFloat = 0.7
	static let minScale: 			   CGFloat = 10
	static let leftAxisMin: 		   Double = 1
	static let leftAxisMax: 		   Double = 20
	static let basicXAxisGranularity:  Double = 86400
	static let xAxisLabelCount: 	   Int = 4
	static let basicAnimationDuration: TimeInterval = 1
}
