//
//  UIImage+Resize.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 07.11.2023.
//

import UIKit

extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
