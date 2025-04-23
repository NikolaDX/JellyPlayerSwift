//
//  StretchyModifier.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import SwiftUI

struct Stretchy: ViewModifier {
    var isTop = true

    func heightFor(_ reader: GeometryProxy) -> CGFloat {
        let height = reader.size.height
        let frame  = reader.frame(in: .global)
        let deltaY = isTop ? frame.minY : (UIScreen.main.bounds.size.height - frame.maxY)
        return height + max(0, deltaY)
    }

    func offsetFor(_ reader: GeometryProxy) -> CGFloat {
        guard isTop else { return 0 }
        let frame  = reader.frame(in: .global)
        let deltaY = frame.minY
        return min(0, -deltaY)
    }

    func body(content: Content) -> some View {
        GeometryReader { reader in
            Color.clear
                .overlay(
                    content
                        .aspectRatio(contentMode: .fill)
                        .frame(width: reader.size.width, height: heightFor(reader), alignment: .top),
                    alignment: .top
                )
                .clipped()
                .frame(height: heightFor(reader))
                .offset(y: offsetFor(reader))
        }
    }
}

extension View {
    func stretchy(isTop: Bool = true) -> some View {
        self.modifier(Stretchy(isTop: isTop))
    }
}
