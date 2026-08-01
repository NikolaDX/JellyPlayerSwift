//
//  AlbumsDiscoBallView.swift
//  JellyPlayerSwift
//
//  Created by Nikola on 26. 7. 2026..
//

import SwiftUI
import CoreMotion

@Observable
final class MotionManager {
    private(set) var pitch: Double = 0
    private(set) var roll: Double = 0
    
    private var referenceGravityX: Double = 0
    private var referenceGravityY: Double = 0

    private var lastGravity: CMAcceleration?
    private var hasCalibrated = false

    private var stillSince: Date?
    private let movementThreshold = 0.015
    private let recalibrationDelay: TimeInterval = 2.5

    private let manager = CMMotionManager()
    private let smoothing = 0.2

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        
        hasCalibrated = false
        lastGravity = nil
        stillSince = nil

        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            
            let gravity = data.gravity

            if !hasCalibrated {
                referenceGravityX = gravity.x
                referenceGravityY = gravity.y
                hasCalibrated = true
            }

            if let lastGravity {
                let movement =
                    abs(gravity.x - lastGravity.x) +
                    abs(gravity.y - lastGravity.y)

                if movement < movementThreshold {
                    if stillSince == nil {
                        stillSince = Date()
                    } else if Date().timeIntervalSince(stillSince!) >= recalibrationDelay {
                        referenceGravityX += (gravity.x - referenceGravityX) * 0.01
                        referenceGravityY += (gravity.y - referenceGravityY) * 0.01
                    }
                } else {
                    stillSince = nil
                }
            }

            lastGravity = gravity

            let targetRoll = (gravity.x - referenceGravityX) * 80
            let targetPitch = -(gravity.y - referenceGravityY) * 80

            roll += (targetRoll - roll) * smoothing
            pitch += (targetPitch - pitch) * smoothing
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}

struct SpherePoint: Identifiable {
    let id: String
    let album: Album
    let baseX: Double
    let baseY: Double
    let baseZ: Double
}

struct AlbumsDiscoBallView: View {
    @Namespace private var albumViewAnimation
    @State private var viewModel = ViewModel()
    @State private var motion = MotionManager()

    var rotationSpeed: Double = 4

    private let rollSensitivity = 1.2
    private let pitchSensitivity = 1.2

    init(rotationSpeed: Double = 4) {
        self.rotationSpeed = rotationSpeed
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading albums…")
            } else {
                GeometryReader { geo in
                    let size = min(geo.size.width, geo.size.height)
                    let radius = size * 0.42
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    
                    let countFactor = max(1.0, sqrt(Double(viewModel.points.count) / 30.0))
                    let baseItemSize = (size * 0.18) / countFactor

                    TimelineView(.animation) { timeline in
                        let autoYDegrees = timeline.date.timeIntervalSinceReferenceDate * rotationSpeed
                        let angleY = Angle(degrees: motion.roll * rollSensitivity + autoYDegrees).radians
                        let angleX = Angle(degrees: motion.pitch * pitchSensitivity).radians

                        let projected = viewModel.points.map { pt -> (SpherePoint, CGPoint, CGFloat, CGFloat) in
                            let cosY = cos(angleY), sinY = sin(angleY)
                            let x1 = pt.baseX * cosY - pt.baseZ * sinY
                            let z1 = pt.baseX * sinY + pt.baseZ * cosY
                            let y1 = pt.baseY

                            let cosX = cos(angleX), sinX = sin(angleX)
                            let y2 = y1 * cosX - z1 * sinX
                            let z2 = y1 * sinX + z1 * cosX

                            let screen = CGPoint(
                                x: center.x + CGFloat(x1) * radius,
                                y: center.y + CGFloat(y2) * radius
                            )
                            let depth = (z2 + 1) / 2
                            let scale = 0.45 + depth * 0.7
                            let opacity = 0.35 + depth * 0.65
                            return (pt, screen, CGFloat(scale), CGFloat(opacity))
                        }
                        .sorted { $0.2 < $1.2 }

                        ZStack {
                            ForEach(projected, id: \.0.id) { pt, screen, scale, opacity in
                                NavigationLink {
                                    AlbumTracksView(album: pt.album)
                                        .navigationTransition(.zoom(sourceID: pt.album.Id, in: albumViewAnimation))
                                } label: {
                                    Cover(url: pt.album.coverUrl)
                                        .clipShape(.circle)
                                        .scaleEffect(0.9)
                                }
                                .buttonStyle(.plain)
                                .frame(width: baseItemSize, height: baseItemSize)
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .position(screen)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Album: \(pt.album.Name) by \(pt.album.getArtist)")
                                .contextMenu {
                                    ContextButton(isDestructive: false, text: "Instant mix", systemImage: "safari") {
                                        AlbumService().generateAndPlayInstantMix(albumId: pt.album.Id)
                                    }
                                    ContextButton(isDestructive: false, text: "Download album", systemImage: "arrow.down.circle") {
                                        AlbumService().downloadAlbum(albumId: pt.album.Id)
                                    }
                                }
                            }
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .padding()
            }
        }
        .task {
            viewModel.fetchAlbums()
        }
        .onAppear { motion.start() }
        .onDisappear { motion.stop() }
    }
}

#Preview {
    NavigationStack {
        AlbumsDiscoBallView()
    }
}
