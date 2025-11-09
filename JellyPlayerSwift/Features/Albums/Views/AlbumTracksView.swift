//
//  AlbumTracksView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct AlbumTracksView: View {
    @State private var viewModel: ViewModel
    @State private var songToRemove: Song? = nil
    @State private var showingRemoveDownloadAlert: Bool = false
    @State private var songToAdd: Song? = nil
    @State private var showingAddToPlaylist: Bool = false
    @StateObject private var favoritesService: FavoritesService
    @StateObject private var downloadService: DownloadService
    let spaceBetween: Double = 20
    
    
    init(album: Album) {
        let favorites = FavoritesService()
        let downloads = DownloadService.shared
        
        _favoritesService = StateObject(wrappedValue: favorites)
        _downloadService = StateObject(wrappedValue: downloads)
        viewModel = ViewModel(album: album, favoritesService: favorites, downloadService: downloads)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    AlbumCover(album: viewModel.album)
                        .frame(maxHeight: proxy.size.height / 2)
                        .padding(.bottom, spaceBetween)
                        .accessibilityLabel("Album cover")
                        .accessibilityRemoveTraits(.isImage)
                    
                    Text(viewModel.album.Name)
                        .font(.title)
                        .fontWeight(.bold)
                        .accessibilityLabel("Album name: \(viewModel.album.Name)")
                    
                    if (viewModel.album.AlbumArtists.isEmpty) {
                        Text(viewModel.album.getArtist)
                            .foregroundStyle(.secondary)
                            .font(.headline)
                            .accessibilityLabel("Artist: \(viewModel.album.getArtist)")
                    }
                    else {
                        NavigationLink(destination: ArtistDetailsView(artist: viewModel.album.AlbumArtists[0])) {
                            Text(viewModel.album.getArtist)
                                .foregroundStyle(.secondary)
                                .font(.headline)
                        }
                        .accessibilityLabel("Artist: \(viewModel.album.getArtist)")
                        .accessibilityHint("Double-tap to see all albums from this artist")
                    }
                    
                    Subheadline("\(viewModel.album.PremiereDate?.prefix(4) ?? "")")
                        .padding(.bottom, spaceBetween)
                        .accessibilityLabel("Release year: \(viewModel.album.PremiereDate?.prefix(4) ?? "")")
                    
                    AsyncView(isLoading: $viewModel.isLoading) {
                        HStack(spacing: 10) {
                            NiceIconButton("Play", buttonImage: "play.fill") {
                                if (!viewModel.songs.isEmpty) {
                                    viewModel.playSong(viewModel.songs[0])
                                }
                            }
                            .accessibilityHint("Play all songs from this album")
                            
                            NiceIconButton("Shuffle", buttonImage: "shuffle") {
                                if (!viewModel.songs.isEmpty) {
                                    viewModel.shufflePlay()
                                }
                            }
                            .accessibilityLabel("Shuffle")
                            .accessibilityHint("Shuffle all songs from this album")
                        }
                        .padding(.bottom, spaceBetween)
                        
                        ForEach(viewModel.songs, id: \.Id) { song in
                            AlbumTrackRow(song)
                                .onTapGesture {
                                    viewModel.playSong(song)
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Song: \(song.Name)")
                                .accessibilityHint("Double-tap to play")
                                .contextMenu {
                                    if song.UserData.IsFavorite {
                                        ContextButton(isDestructive: true, text: "Remove from favorites", systemImage: "star.slash") {
                                            viewModel.removeFromFavorites(song)
                                        }
                                        .accessibilityHint("Remove this song from favorites")
                                    } else {
                                        ContextButton(isDestructive: false, text: "Add to favorites", systemImage: "star") {
                                            viewModel.addToFavorites(song)
                                        }
                                        .accessibilityHint("Add this song to favorites")
                                    }
                                    
                                    if song.localFilePath != nil {
                                        ContextButton(isDestructive: true, text: "Remove download", systemImage: "trash") {
                                            songToRemove = song
                                            showingRemoveDownloadAlert = true
                                        }
                                        .accessibilityHint("Remove this song from downloads")
                                    } else {
                                        ContextButton(isDestructive: false, text: "Download", systemImage: "arrow.down.circle") {
                                            viewModel.downloadSong(song)
                                        }
                                        .accessibilityHint("Download this song for offline listening")
                                    }
                                    
                                    ContextButton(isDestructive: false, text: "Add to playlist", systemImage: "plus.circle") {
                                        songToAdd = nil
                                        DispatchQueue.main.async {
                                            songToAdd = song
                                        }
                                    }
                                    .accessibilityHint("Add this song to playlist")
                                    
                                    ContextButton(isDestructive: false, text: "Instant mix", systemImage: "safari") {
                                        viewModel.generateInstantMix(song)
                                    }
                                    .accessibilityHint("Create mix based on this song")
                                }
                        }
                    }
                }
                .padding(spaceBetween)
            }
        }
        .clipped()
        .onChange(of: songToAdd) {
            if let _ = songToAdd {
                showingAddToPlaylist = true
            }
        }
        .sheet(isPresented: $showingAddToPlaylist) {
            AddSongToPlaylistView(songToAdd!)
        }
        .alert("Remove download", isPresented: $showingRemoveDownloadAlert, presenting: songToRemove) { song in
            Button("Remove", role: .destructive) {
                downloadService.removeDownload(song)
            }
            Button("Cancel", role: .cancel) { }
        } message: { song in
            Text("Are you sure you want to remove the download for \"\(song.Name)\"?")
        }
        .onAppear {
            viewModel.fetchSongs()
        }
    }
}

#Preview {
    @Previewable @Namespace var albumViewAnimation
    AlbumTracksView(album: Album(Id: "id", Name: "Name", AlbumArtist: "Artist", AlbumArtists: [], DateCreated: "", PremiereDate: ""))
}
