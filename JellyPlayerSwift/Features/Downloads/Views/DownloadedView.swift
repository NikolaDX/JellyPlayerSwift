//
//  DownloadedView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/24/25.
//

import SwiftUI

struct DownloadedView: View {
    @ObservedObject var downloadService: DownloadService
    
    var body: some View {
        SongsView(songs: downloadService.downloads)
            .navigationTitle("Downloaded")
    }
}

#Preview {
    DownloadedView(downloadService: DownloadService.shared)
}
