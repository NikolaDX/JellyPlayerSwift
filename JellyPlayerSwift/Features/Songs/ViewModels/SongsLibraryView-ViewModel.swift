//
//  SongsLibraryView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

extension SongsLibraryView {
    @Observable
    class ViewModel {
        var songs: [Song] {
            LibraryService.shared.songs
        }
        
        var isLoading: Bool {
            LibraryService.shared.isLoading
        }
    }
}
