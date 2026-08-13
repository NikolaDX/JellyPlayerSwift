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
        var albums: [Album] {
            Array(LibraryService.shared.albums.prefix(30))
        }
        
        var isLoading: Bool {
            LibraryService.shared.isLoading && albums.isEmpty
        }
        
        var points: [SpherePoint] {
            fibonacciSphere(albums: albums)
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
