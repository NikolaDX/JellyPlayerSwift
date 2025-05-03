//
//  ThemeService.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/3/25.
//

import SwiftUI

enum ThemeMode: String, CaseIterable, Identifiable {
    case system, light, dark
    
    var id: String { rawValue }
}

class ThemeService: ObservableObject {
    @Published var selectedMode: ThemeMode {
        didSet {
            UserDefaults.standard.set(selectedMode.rawValue, forKey: modeKey)
        }
    }
    
    @Published var selectedAccentColor: Color {
        didSet {
            saveAccentColorToUserDefaults(selectedAccentColor)
        }
    }
    
    let availableAccentColors: [Color] = [.blue, .red, .yellow, .green, .pink, .purple, .orange, .mint, .teal]
    
    init() {
        let rawValue = UserDefaults.standard.string(forKey: modeKey) ?? ThemeMode.system.rawValue
        selectedMode = ThemeMode(rawValue: rawValue) ?? .system
        selectedAccentColor = ThemeService.loadAccentColorFromUserDefaults()
    }
    
    private func saveAccentColorToUserDefaults(_ color: Color) {
        if let uiColor = UIColor(color).cgColor.components {
            UserDefaults.standard.set(uiColor[0], forKey: accentRKey)
            UserDefaults.standard.set(uiColor[1], forKey: accentGKey)
            UserDefaults.standard.set(uiColor[2], forKey: accentBKey)
        }
    }
    
    static private func loadAccentColorFromUserDefaults() -> Color {
        let r = UserDefaults.standard.double(forKey: accentRKey)
        let g = UserDefaults.standard.double(forKey: accentGKey)
        let b = UserDefaults.standard.double(forKey: accentBKey)
        
        if r == 0 && g == 0 && b == 0 {
            return .blue
        }
        
        return Color(red: r, green: g, blue: b)
    }
}
