//
//  Cover.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import Kingfisher
import SwiftUI

struct Cover: View {
    private let url: URL?
    @State private var failed = false
    
    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        if !failed {
            KFImage(url)
                .cacheOriginalImage(false)
                .diskCacheExpiration(.days(7))
                .onFailure { _ in
                    failed = true
                }
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    Cover(url: URL(string: ""))
}
