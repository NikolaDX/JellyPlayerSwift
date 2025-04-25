//
//  DownloadProgress.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/25/25.
//

import SwiftUI

struct DownloadProgressView: View {
    @ObservedObject var downloadService: DownloadService

    var body: some View {
        if downloadService.isDownloading {
            ProgressView(value: downloadService.averageDownloadProgress, total: 1.0)
                .padding(.horizontal)
        }
    }
}

#Preview {
    DownloadProgressView(downloadService: DownloadService.shared)
}
