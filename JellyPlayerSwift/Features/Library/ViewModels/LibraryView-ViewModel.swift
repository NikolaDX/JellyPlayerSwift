//
//  LibraryView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/22/25.
//

import SwiftUI

struct LibraryOption {
    let id = UUID()
    let title: String
    let iconName: String
    let viewToShow: AnyView
}

extension LibraryView {
    @Observable
    class ViewModel {
        let libraryOptions: [LibraryOption] = [
            LibraryOption(title: "Playlists", iconName: "music.note.list", viewToShow: AnyView(Heading("Playlists"))),
            LibraryOption(title: "Artists", iconName: "music.microphone", viewToShow: AnyView(ArtistsView())),
            LibraryOption(title: "Albums", iconName: "rectangle.stack", viewToShow: AnyView(AlbumsLibraryView())),
            LibraryOption(title: "Songs", iconName: "music.note", viewToShow: AnyView(SongsLibraryView())),
            LibraryOption(title: "Genres", iconName: "guitars", viewToShow: AnyView(GenresView())),
            LibraryOption(title: "Favorites", iconName: "star", viewToShow: AnyView(FavoritesView())),
            LibraryOption(title: "Downloaded", iconName: "arrow.down.circle", viewToShow: AnyView(DownloadedView(downloadService: DownloadService.shared)))
        ]
    }
}
