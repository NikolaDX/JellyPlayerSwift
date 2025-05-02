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
        var showingServerInvalid: Bool = false
        
        func setServerProcedure() async {
            let jellyfinService = JellyfinService()
            let isValid = await jellyfinService.isValidJellyfinServer(serverText)
            if isValid {
                showingLogin = true
            } else {
                showingServerInvalid = true
            }
        }
    }
}
