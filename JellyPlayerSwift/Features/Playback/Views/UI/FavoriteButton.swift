//
//  FavoriteButton.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

struct FavoriteButton: View {
    private var isFavorite: Bool
    private var toggleFavorite: () -> Void

    init(isFavorite: Bool, toggleFavorite: @escaping () -> Void) {
        self.isFavorite = isFavorite
        self.toggleFavorite = toggleFavorite
    }
    
    var body: some View {
        Button {
            toggleFavorite()
        } label: {
            isFavorite ?
            Image(systemName: "star.fill")
            : Image(systemName: "star")
        }
    }
}

#Preview {
    FavoriteButton(isFavorite: false) {
        
    }
}
