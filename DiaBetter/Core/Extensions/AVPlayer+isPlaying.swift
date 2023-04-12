//
//  AVPlayer+isPlaying.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 12.04.2023.
//

import AVFoundation

extension AVPlayer {
	var isPlaying: Bool {
		return rate != 0 && error == nil
	}
}
