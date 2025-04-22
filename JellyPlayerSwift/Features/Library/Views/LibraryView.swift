//
//  LibraryView.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/22/25.
//

import SwiftUI

struct LibraryView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.libraryOptions, id: \.id) { option in
                NavigationLink {
                    option.viewToShow
                } label: {
                    HStack {
                        Image(systemName: option.iconName)
                            .frame(minWidth: 30)
                        Headline(option.title)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Library")
        }
    }
}

#Preview {
    LibraryView()
}
