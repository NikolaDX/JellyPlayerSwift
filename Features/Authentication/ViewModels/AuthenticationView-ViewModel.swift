//
//  AuthenticationView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import Foundation

extension AuthenticationView {
    @Observable
    class ViewModel {
        private var serverUrl: String
        
        var username: String = ""
        var password: String = ""
        
        var errorMessage: String? = nil
        var isLoading = false
        var showingSuccessMessage = false
        
        init(serverUrl: String) {
            self.serverUrl = serverUrl
        }
        
        func logIn() async {
            self.isLoading = true
            let jellyfinService = JellyfinService()
            
            do {
                try await jellyfinService.authenticateUser(server: serverUrl, username: username, password: password)
                showingSuccessMessage = true
            } catch {
                errorMessage = error.localizedDescription
            }
            
            self.isLoading = false
        }
    }
}
