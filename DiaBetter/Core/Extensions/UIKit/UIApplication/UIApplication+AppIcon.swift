//
//  UIApplication+AppIcon.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 19.06.2023.
//

import UIKit

func getAppIconImage() -> Data? {
    guard
        let iconsDictionary = Bundle.main.infoDictionary?[Keys.bundleIcons] as? NSDictionary,
        let primaryIconsDictionary = iconsDictionary[Keys.primaryIcon] as? NSDictionary,
        let iconFiles = primaryIconsDictionary[Keys.iconFiles] as? NSArray,
        let lastIcon = iconFiles.lastObject as? String,
        let icon = UIImage(named: lastIcon)
    else {
        return nil
    }
    return icon.pngData()
}

// MARK: - Keys
fileprivate enum Keys {
    static let bundleIcons = "CFBundleIcons"
    static let primaryIcon = "CFBundlePrimaryIcon"
    static let iconFiles = "CFBundleIconFiles"
}
