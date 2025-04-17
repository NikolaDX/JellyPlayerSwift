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
    
    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        KFImage(url)
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    Cover(url: URL(string: ""))
}
