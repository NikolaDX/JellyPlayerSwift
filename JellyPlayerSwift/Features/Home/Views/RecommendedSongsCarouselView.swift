//
//  RecommendedSongsCarouselView.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 8. 7. 2026..
//

import SwiftUI

struct RecommendedSongsCarouselView: View {
    @State private var viewModel = ViewModel()
    
    @StateObject var favoritesService = FavoritesService()
    @StateObject var downloadService = DownloadService.shared
    
    @State private var showingAddToPlaylist: Bool = false
    @State private var songToAdd: Song? = nil
    @State private var songToRemove: Song? = nil
    @State private var showingRemoveDownloadAlert: Bool = false
    
    private let rows = [
        GridItem(.fixed(60), spacing: 12),
        GridItem(.fixed(60), spacing: 12),
        GridItem(.fixed(60), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Headline("Recommended For You")
                .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 210)
            } else if viewModel.recommendedSongs.isEmpty {
                Text("Keep listening! Your personalized recommendations will appear here.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 18) {
                        ForEach(viewModel.recommendedSongs, id: \.Id) { song in
                            Button {
                                PlaybackService.shared.playAndBuildQueue(song, songsToPlay: viewModel.recommendedSongs)
                            } label: {
                                SongRow(song)
                                    .frame(width: 290, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                if isFavorite(song) {
                                    ContextButton(isDestructive: true, text: "Remove from favorites", systemImage: "star.slash") {
                                        Task { @MainActor in
                                            await favoritesService.removeFromFavorites(song: song)
                                        }
                                    }
                                    .accessibilityHint("Remove this song from favorites")
                                } else {
                                    ContextButton(isDestructive: false, text: "Add to favorites", systemImage: "star") {
                                        Task { @MainActor in
                                            await favoritesService.addSongToFavorites(song: song)
                                        }
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
                                        downloadService.downloadSong(song)
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
                                    Task {
                                        let songsToPlay = await SongsService().generateInstantMix(songId: song.Id)
                                        PlaybackService.shared.playAndBuildQueue(songsToPlay[0], songsToPlay: songsToPlay)
                                    }
                                }
                                .accessibilityHint("Create mix based on this song")
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 210)
            }
        }
        .task {
            await viewModel.loadMLRecommendations()
        }
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
    }
    
    private func isFavorite(_ song: Song) -> Bool {
        LibraryService.shared.songs.first(where: { $0.Id == song.Id })?.UserData.IsFavorite ?? song.UserData.IsFavorite
    }
}

#Preview {
    RecommendedSongsCarouselView()
}
