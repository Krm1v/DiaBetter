//
//  ChartsDateFormatter.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 16.05.2023.
//

import UIKit
import Charts

final class ChartsDateFormatter: NSObject, AxisValueFormatter {
	//MARK: - Properties
	private let dateFormatter = DateFormatter()
	
	//MARK: - Init
	override init() {
		super.init()
	}
	
	convenience init(format: DateFormats) {
		self.init()
		self.dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
		self.dateFormatter.locale = .current
		self.dateFormatter.dateFormat = format.rawValue
	}

	//MARK: - Public methods
	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		return dateFormatter.string(from: Date(timeIntervalSince1970: value))
	}
}
