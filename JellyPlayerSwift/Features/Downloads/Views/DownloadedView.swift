//
//  DownloadedView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/2/25.
//

import SwiftUI

struct DownloadedView: View {
    @ObservedObject var downloadService = DownloadService.shared
        
    var body: some View {
        SongsView(songs: downloadService.downloads)
            .navigationTitle("Downloaded")
    }
}

#Preview {
    DownloadedView()
}
