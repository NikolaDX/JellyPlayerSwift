//
//  SingleFingerDragGestureView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 5/9/25.
//

import SwiftUI
import UIKit

struct SingleFingerDragGestureView: UIViewRepresentable {
    var onChanged: (CGSize) -> Void
    var onEnded: (CGSize) -> Void

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: SingleFingerDragGestureView
        var startLocation: CGPoint = .zero

        init(_ parent: SingleFingerDragGestureView) {
            self.parent = parent
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view)

            switch gesture.state {
            case .changed:
                parent.onChanged(CGSize(width: translation.x, height: translation.y))
            case .ended, .cancelled, .failed:
                parent.onEnded(CGSize(width: translation.x, height: translation.y))
            default:
                break
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = context.coordinator
        view.addGestureRecognizer(panGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

