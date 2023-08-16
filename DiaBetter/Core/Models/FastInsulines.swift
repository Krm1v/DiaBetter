//
//  LongInsulines.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.04.2023.
//

import Foundation

protocol SettingsMenuDatasourceProtocol {
	var title: String { get }
}

enum FastInsulines: String, CaseIterable, SettingsMenuDatasourceProtocol {
	case actrapid
	case afrezza
	case apidra
	case gensulinR
	case humalog
	case humalogR
	case liprolog
	case novolinR
	case novolog
	case novoRapid
	case regular
	case u500
	case fiasp
	case other
	
	var title: String {
		switch self {
		case .actrapid:
			return "Actrapid"
		case .afrezza:
			return "Afrezza"
		case .apidra:
			return "Apidra"
		case .gensulinR:
			return "Gensulin R"
		case .humalog:
			return "Humalog"
		case .humalogR:
			return "Humalog R"
		case .liprolog:
			return "Liprolog"
		case .novolinR:
			return "Novolin R"
		case .novolog:
			return "Novolog"
		case .novoRapid:
			return "NovoRapid"
		case .regular:
			return "Regular"
		case .u500:
			return "U-500"
		case .fiasp:
			return "Fiasp"
		case .other:
			return "Other"
		}
	}
}
