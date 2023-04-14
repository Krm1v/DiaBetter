//
//  LongInsulines.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.04.2023.
//

import Foundation

enum LongInsulines: String, CaseIterable, SettingsMenuDatasourceProtocol {
	case basaglar
	case gensulinG
	case humalogMix50
	case humalogMix75
	case humiin70
	case humulinN
	case insulatard
	case insumanN
	case lantus
	case levemir
	case mixtard30
	case novolin70
	case novolinN
	case novolog30
	case novolog50
	case novoMix30
	case novoMix50
	case novoMix70
	case novoRapid70
	case nph
	case protaphane
	case ryzodeg
	case toujeo
	case tresiba
	case other
	
	var title: String {
		switch self {
		case .basaglar:
			return "Basaglar"
		case .gensulinG:
			return "Gensulin G"
		case .humalogMix50:
			return "Humalog Mix 50/50"
		case .humalogMix75:
			return "Humalog Mix 75/25"
		case .humiin70:
			return "Humilin 70/30"
		case .humulinN:
			return "Humulin N"
		case .insulatard:
			return "Insulatard"
		case .insumanN:
			return "Insuman N"
		case .lantus:
			return "Lantus"
		case .levemir:
			return "Levemir"
		case .mixtard30:
			return "Mixtard 30"
		case .novolin70:
			return "Novolin 70/30"
		case .novolinN:
			return "Novolin N"
		case .novolog30:
			return "Novolog 30/70"
		case .novolog50:
			return "Novolog 50/50"
		case .novoMix30:
			return "NovoMix 30"
		case .novoMix50:
			return "NovoMix 50"
		case .novoMix70:
			return "NovoMix 70"
		case .novoRapid70:
			return "NovoRapid 70/30"
		case .nph:
			return "NPH"
		case .protaphane:
			return "Protaphane"
		case .ryzodeg:
			return "Ryzodeg"
		case .toujeo:
			return "Toujeo"
		case .tresiba:
			return "Tresiba"
		case .other:
			return "Other"
		}
	}
}
