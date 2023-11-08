//
//  UIImageView+SetImage.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 14.04.2023.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(_ url: URL, options: KingfisherOptionsInfo? = nil) {
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: Assets.userImagePlaceholder.image,
            options: options)
    }
    
    func setImage(_ data: Data) {
        self.image = UIImage(data: data)
    }
    
    func setImage(_ asset: ImageAsset) {
        self.image = asset.image
    }
}
