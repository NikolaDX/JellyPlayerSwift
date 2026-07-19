//
//  Color-Luminance.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 19. 7. 2026..
//

import Foundation
import SwiftUI

extension Color {
    var luminance: Double {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return 0.5
        }
        
        let r = components[0], g = components[1], b = components[2]
        return 0.299 * r + 0.587 * g + 0.114 * b
    }
    
    var readableForeground: Color {
        luminance > 0.6 ? .black : .white
    }
}
