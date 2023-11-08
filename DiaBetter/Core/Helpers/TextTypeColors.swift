//
//  TextTypeColors.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.07.2023.
//

import UIKit

enum TextTypeColors {
	case regular
	case info
	case alert
	case largeTitle

	var color: UIColor {
		switch self {
		case .regular:    return UIColor.white
		case .info:       return UIColor.systemGray
		case .alert:   	  return UIColor.red
		case .largeTitle: return Colors.customPink.color
		}
	}
}
