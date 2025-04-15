//
//  SettingsView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Foundation

extension SettingsView {
    @Observable
    class ViewModel {
        var serverText: String = UserDefaults.standard.string(forKey: serverKey) ?? ""
        var showingLogin: Bool = false
    }
}
