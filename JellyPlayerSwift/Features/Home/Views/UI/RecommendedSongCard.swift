//
//  RecommendedSongCard.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 8. 7. 2026..
//

import SwiftUI

struct RecommendedSongCard: View {
    let song: Song
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 115, height: 115)
                
                Image(systemName: "music.note")
                    .font(.title)
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(song.Name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(song.Artists.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 115, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Recommended song: \(song.Name) by \(song.Artists.joined(separator: ", "))")
    }
}
