//
//  UIApplication+AppIcon.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.06.2023.
//

import UIKit

func getAppIconImage() -> Data? {
		guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? NSDictionary,
			  let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? NSDictionary,
			  let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? NSArray,
			  let lastIcon = iconFiles.lastObject as? String,
			  let icon = UIImage(named: lastIcon) else {
			return nil
		}
	return icon.pngData()
}
