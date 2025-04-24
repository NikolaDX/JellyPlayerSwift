//
//  SpinningVinyl.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/18/25.
//

import SwiftUI

struct SpinningVinyl: View {
    let song: Song
    let isPlaying: Bool
    @Binding var currentTime: Double
    @Binding var isScrubbing: Bool
    
    @State private var rotation: Double = 0
    @State private var timer: Timer?
    @State private var isDecelerating: Bool = false
    
    private let rotSpeed: Double = 0.2
    
    var body: some View {
        LargeSongCover(song)
            .clipShape(Circle())
            .rotationEffect(.degrees(rotation))
            .onAppear {
                if isPlaying {
                    startSpinning()
                }
            }
            .onChange(of: isPlaying) { _, newValue in
                if newValue {
                    startSpinning()
                } else {
                    stopSpinningSmoothly()
                }
            }
            .onChange(of: currentTime) { _, newValue in
                if isScrubbing {
                    withAnimation(.easeOut(duration: 0.3)) {
                        rotation = newValue * 3
                    }
                }
            }
    }
    
    func startSpinning() {
        timer?.invalidate()
        timer = nil
        isDecelerating = false

        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if !isScrubbing {
                rotation += rotSpeed
            }
        }
    }

    func stopSpinningSmoothly() {
        guard !isDecelerating else { return }
        isDecelerating = true

        timer?.invalidate()
        timer = nil

        var currentSpeed = 0.3
        let decelerationRate = 0.98
        let minSpeed = 0.01

        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { t in
            currentSpeed *= decelerationRate
            rotation += currentSpeed

            if currentSpeed < minSpeed {
                t.invalidate()
                timer = nil
                isDecelerating = false
            }
        }
    }
}

#Preview {
    @Previewable @State var currentTime: Double = 0
    @Previewable @State var isScrubbing: Bool = false
    SpinningVinyl(song: Song(Id: "Id", Name: "Name", IndexNumber: 1, Album: "Album", AlbumId: "Id", RunTimeTicks: 120000, Artists: ["Artist"], UserData: UserData(IsFavorite: false)), isPlaying: false, currentTime: $currentTime, isScrubbing: $isScrubbing)
}
