//
//  Datasource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.06.2023.
//

import UIKit

struct AppInfoCellModel: Hashable {
    let appIcon: Data
    let appVersion: String
    let buildVersion: String
    let companyInfo: String
}

struct CreditsListCellModel: Hashable {
    let title: String
    let item: CreditsListCellItems
}

enum CreditsListCellItems: Hashable {
    case website
    case instagram
    case twitter
    case fb
    case linkedIn
    case termsAndConditions
    case privacyPolicy
    
#warning("TODO: Add terms and conditions")
    var link: String {
        switch self {
        case .website: 	 	 	  return "https://chisw.com"
        case .instagram: 	 	  return "https://instagram.com/chi.software?igshid=MmJiY2I4NDBkZg=="
        case .twitter: 	 	 	  return "https://twitter.com/chisoftware?s=21&t=O23B1d3KpAdx2JvVnyBgcg"
        case .fb:			 	  return "https://www.facebook.com/chisoftware/"
        case .linkedIn: 	 	  return "https://www.linkedin.com/company/chisoftware/mycompany/"
        case .termsAndConditions: return ""
        case .privacyPolicy: 	  return "https://chisw.com/privacy-policy/"
        }
    }
}

enum CreditsSceneSections: Int, Hashable {
    case appInfoSection
    case socialMediaSection
    case termsAndConditionsSection
}

enum CreditsSceneItems: Hashable {
    case appInfoItem(AppInfoCellModel)
    case listItem(CreditsListCellModel)
}
