//
//  StretchableHeader.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/23/25.
//

import Kingfisher
import SwiftUI

struct StretchableHeader: View {
    var imageUrl: URL?
    var initialHeaderHeight: CGFloat = UIScreen.main.bounds.height * 0.25
    
    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            if geometry.frame(in: .global).minY <= 0 {
                KFImage(imageUrl).resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
            } else {
                KFImage(imageUrl).resizable()
                    .aspectRatio(contentMode: .fill)
                    .offset(y: -geometry.frame(in: .global).minY)
                    .frame(width: geometry.size.width,
                           height: geometry.size.height
                            + geometry.frame(in: .global).minY)
            }
        }.frame(maxHeight: UIScreen.main.bounds.size.height / 2)
    }
}

#Preview {
    StretchableHeader()
}
