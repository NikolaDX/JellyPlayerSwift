//
//  SpinningVinyl.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/18/25.
//

import SwiftUI

struct SpinningVinyl: View {
    let coverUrl: URL?
    let isPlaying: Bool
    
    @State private var rotation: Double = 0
    @State private var displayRotation: Double = 0
    @State private var timer: Timer?
    @State private var isDecelerating: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            Cover(url: coverUrl)
                .clipShape(Circle())
            
            Circle()
                .fill(Color.black)
                .frame(width: 80, height: 80)
        }
        .rotationEffect(.degrees(displayRotation))
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
    }
    
    func startSpinning() {
        timer?.invalidate()
        timer = nil
        isDecelerating = false

        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            rotation += 0.3
            displayRotation = rotation.truncatingRemainder(dividingBy: 360)
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
            displayRotation = rotation.truncatingRemainder(dividingBy: 360)

            if currentSpeed < minSpeed {
                t.invalidate()
                timer = nil
                isDecelerating = false
            }
        }
    }
}

#Preview {
    SpinningVinyl(coverUrl: URL(string: ""), isPlaying: false)
}
