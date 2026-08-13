//
//  AlbumsLibraryView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

extension AlbumsLibraryView {
    @Observable
    class ViewModel {
        var albums: [Album] {
            LibraryService.shared.albums
        }
        
        var isLoading: Bool {
            LibraryService.shared.isLoading && albums.isEmpty
        }
    }
}
