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
                Cover(url: viewModel.coverUrl)
                    .frame(maxWidth: 100)
                    .clipShape(.rect(cornerRadius: 10))
                
                VStack(alignment: .leading) {
                    Text(viewModel.songName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(viewModel.songArtists)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            List(viewModel.queue.indices, id: \.self) { index in
                HStack {
                    Text("\(index + 1)")
                        .frame(width: 30)
                    
                    VStack(alignment: .leading) {
                        Text(viewModel.queue[index].Name)
                            .lineLimit(1)
                            .font(.headline)
                        
                        Text(viewModel.queue[index].Artists.joined(separator: ", "))
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    if index == viewModel.currentIndex {
                        Image(systemName: "play.circle.fill")
                    }
                }
                .listRowBackground(Color.clear)
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }
}

#Preview {
    QueueView()
}
