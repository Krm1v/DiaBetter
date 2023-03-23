//
//  UIImage+URL.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 22.03.2023.
//

import UIKit

extension UIImage {
	convenience init?(url: URL?) {
		guard let url = url else { return nil }
		do {
			self.init(data: try Data(contentsOf: url))
		} catch {
			print("Cannot load image from url: \(url) with error: \(error)")
			return nil
		}
	}
}
