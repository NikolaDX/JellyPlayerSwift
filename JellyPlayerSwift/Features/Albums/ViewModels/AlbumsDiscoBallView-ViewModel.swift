//
//  AlbumsDiscoBallView-ViewModel.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 26. 7. 2026..
//

import Foundation
import SwiftUI

extension AlbumsDiscoBallView {
    @Observable
    class ViewModel {
        var albums: [Album] = []
        var points: [SpherePoint] = []
        
        var isLoading: Bool = false
        
        var lastFetched: Date?
        let cacheLifetime: TimeInterval = 300
        
        func fetchAlbums(forceRefresh: Bool = false) {
            if !albums.isEmpty { return }
            
            if !forceRefresh,
                let lastFetched,
                Date().timeIntervalSince(lastFetched) < cacheLifetime,
                !albums.isEmpty {
                return
            }
            
            isLoading = true
            let albumsService = AlbumService()
            Task { @MainActor in
                self.albums = await albumsService.fetchAlbums()
                self.lastFetched = Date()
                self.points = fibonacciSphere(albums: self.albums)
                withAnimation {
                    isLoading = false
                }
            }
        }
        
        func fibonacciSphere(albums: [Album]) -> [SpherePoint] {
            let n = albums.count
            guard n > 0 else { return [] }
            let goldenAngle = Double.pi * (3 - sqrt(5))

            return albums.enumerated().map { i, album in
                let y = 1 - (Double(i) / Double(max(n - 1, 1))) * 2
                let radiusAtY = sqrt(max(0, 1 - y * y))
                let theta = goldenAngle * Double(i)
                let x = cos(theta) * radiusAtY
                let z = sin(theta) * radiusAtY
                return SpherePoint(id: album.Id, album: album, baseX: x, baseY: y, baseZ: z)
            }
        }
    }
}
