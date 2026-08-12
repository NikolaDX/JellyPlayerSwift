//
//  HomeScreenView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/2/25.
//

import Kingfisher
import SwiftUI

struct HomeScreenView: View {
    @ObservedObject var networkService = NetworkService.shared
    @State private var navigationPath = NavigationPath()
    @AppStorage(accessKey) private var access: String?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if networkService.isConnected {
                    if let _ = access {
                        RecommendedSongsCarouselView()
                            .padding(.top)
                        
                        AlbumsDiscoBallView()
                            .accessibilityHidden(true)
                    } else {
                        ServerNotConfiguredView()
                    }
                } else {
                    NetworkUnavailableView()
                }
            }
            .navigationTitle("JellyPlayer")
        }
    }
}

#Preview {
    HomeScreenView()
}
