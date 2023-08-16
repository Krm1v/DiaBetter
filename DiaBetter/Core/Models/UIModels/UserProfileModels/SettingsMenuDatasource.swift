//
//  Insulines.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 03.04.2023.
//

import Foundation

protocol UserParametersProtocol {
	var title: String { get }
}

enum UserTreatmentSettings: Hashable {
	enum DiabetesType: String, CaseIterable, UserParametersProtocol {
		case type1
		case type2
		case gestational
		case prediabetes
		case other

		var title: String {
			switch self {
			case .type1:
				return "Type 1"
			case .type2:
				return "Type 2"
			case .gestational:
				return "Gestational Diabetes"
			case .prediabetes:
				return "Prediabetes"
			case .other:
				return "Other"
			}
		}
	}

	enum FastInsulines: String, CaseIterable, UserParametersProtocol {
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

	enum LongInsulines: String, CaseIterable, UserParametersProtocol {
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
}
