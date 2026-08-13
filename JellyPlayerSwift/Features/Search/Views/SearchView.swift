//
//  SearchView.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 11. 8. 2026..
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    if !viewModel.playlists.isEmpty {
                        Title("Playlists")
                            .accessibilityAddTraits(.isHeader)
                        
                        ForEach(viewModel.playlists, id: \.Id) { playlist in
                            NavigationLink {
                                PlaylistSongsView(playlist: playlist)
                            } label: {
                                PlaylistRow(playlist)
                                    .padding()
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Playlist: \(playlist.Name)")
                            .accessibilityHint("Double-tap to view playlist songs")
                        }
                    }
                    
                    if !viewModel.artists.isEmpty {
                        Title("Artists")
                        
                        ForEach(viewModel.artists, id: \.Id) { artist in
                            NavigationLink {
                                ArtistDetailsView(artist: artist)
                            } label: {
                                ArtistListRow(artist: artist)
                                    .padding()
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Artist: \(artist.Name)")
                            .accessibilityHint("Double-tap to view artist albums")
                        }
                    }
                    
                    if !viewModel.albums.isEmpty {
                        Title("Albums")
                        
                        ForEach(viewModel.albums, id: \.Id) { album in
                            NavigationLink {
                                AlbumTracksView(album: album)
                            } label: {
                                AlbumRow(album)
                                    .padding()
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Album: \(album.Name)")
                            .accessibilityHint("Double-tap to view album tracks")
                        }
                    }
                    
                    if !viewModel.songs.isEmpty {
                        Title("Songs")
                        
                        ForEach(viewModel.songs, id: \.Id) { song in
                            Button {
                                PlaybackService.shared.playAndBuildQueue(song, songsToPlay: [song])
                            } label: {
                                SongRow(song)
                                    .padding()
                            }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Song: \(song.Name)")
                            .accessibilityHint("Double-tap to play this song")
                        }
                    }
                    
                    if !viewModel.genres.isEmpty {
                        Title("Genres")
                        
                        ForEach(viewModel.genres, id: \.Id) { genre in
                            NavigationLink {
                                GenreDetailsView(genre: genre)
                            } label: {
                                Headline(genre.Name)
                                    .padding()
                            }
                            .accessibilityLabel("Genre: \(genre.Name)")
                            .accessibilityHint("Double-tap to view albums in this genre")
                        }
                    }
                    
                    if !viewModel.downloads.isEmpty {
                        Title("Downloaded")
                        
                        ForEach(viewModel.downloads, id: \.Id) { song in
                            Button {
                                PlaybackService.shared.playAndBuildQueue(song, songsToPlay: [song])
                            } label: {
                                SongRow(song)
                                    .padding()
                            }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Song: \(song.Name)")
                            .accessibilityHint("Double-tap to play this song")
                        }
                    }
                }
                .padding()
            }
            .foregroundStyle(.primary)
            .searchable(
                text: $viewModel.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for anything..."
            )
            .submitLabel(.search)
            .onSubmit(of: .search) { }
            .accessibilityLabel("Search library")
        }
    }
}

#Preview {
    SearchView()
}
