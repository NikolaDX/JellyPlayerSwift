//
//  AudioOutput.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 22. 7. 2026..
//

import Foundation

enum AudioOutput: String, Codable {
    case speaker
    case headphones
    case bluetooth
    case car
    case airplay
    case usb
    case other
}
