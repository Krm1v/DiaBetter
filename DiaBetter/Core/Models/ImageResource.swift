//
//  ImageResource.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 22.03.2023.
//

import UIKit

enum ImageResource: Hashable {
	case url(URL)
	case data(Data)
	case asset(ImageAsset)
}
