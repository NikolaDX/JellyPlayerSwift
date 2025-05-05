//
//  QueueView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/20/25.
//

import SwiftUI

struct QueueView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            HStack {
                LargeSongCover(viewModel.queue[viewModel.currentIndex])
                    .frame(maxWidth: 100)
                    .clipShape(.rect(cornerRadius: 10))
                
                VStack(alignment: .leading) {
                    Headline(viewModel.songName)
                    Subheadline(viewModel.songArtists)
                }
                
                Spacer()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Current song: \(viewModel.queue[viewModel.currentIndex].Name) by \(viewModel.queue[viewModel.currentIndex].Artists.joined(separator: ", "))")
            
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.queue.indices, id: \.self) { index in
                        QueueRow(
                            song: viewModel.queue[index],
                            songIndex: index,
                            currentIndex: viewModel.currentIndex
                        )
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            viewModel.playSong(songIndex: index)
                        }
                        .deleteDisabled(index == viewModel.currentIndex)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Song: \(viewModel.queue[index].Name) by \(viewModel.queue[index].Artists.joined(separator: ", "))")
                        .accessibilityHint("Double-tap to play")
                        .accessibilityAddTraits(.isButton)
                        .contextMenu {
                            ContextButton(isDestructive: true, text: "Remove from queue", systemImage: "trash") {
                                viewModel.removeFromQueue(index: index)
                            }
                            .accessibilityHint("Remove this song from queue")
                        }
                    }
                    .onDelete { indexSet in
                        if !indexSet.contains(viewModel.currentIndex) {
                            withAnimation {
                                viewModel.removeAtIndexes(indexSet)
                            }
                        }
                    }
                    .onMove { source, destination in
                        withAnimation {
                            viewModel.moveQueueItems(from: source, to: destination)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .onChange(of: viewModel.currentIndex) {
                    withAnimation {
                        proxy.scrollTo(viewModel.currentIndex, anchor: .center)
                    }
                }
                .onAppear {
                    proxy.scrollTo(viewModel.currentIndex, anchor: .center)
                }
            }
        }
    }
}

#Preview {
    QueueView()
}
