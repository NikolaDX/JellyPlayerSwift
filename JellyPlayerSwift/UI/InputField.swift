//
//  InputField.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/15/25.
//

import SwiftUI

struct NiceTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textInputAutocapitalization(.never)
            .padding(.leading)
            .frame(height: 55)
            .background(.secondary.opacity(0.2))
            .clipShape(.rect(cornerRadius: 10))
    }
}

extension View {
    func fieldStyle() -> some View {
        modifier(NiceTextField())
    }
}

struct InputField: View {
    @Binding private var text: String
    private var placeholder: String
    private var censored: Bool
    
    init(text: Binding<String>, censored: Bool, placeholder: String) {
        self._text = text
        self.censored = censored
        self.placeholder = placeholder
    }
    
    var body: some View {
        if censored {
            SecureField(LocalizedStringKey(placeholder), text: $text)
                .fieldStyle()
        } else {
            TextField(LocalizedStringKey(placeholder), text: $text)
                .fieldStyle()
        }
            
    }
}

#Preview {
    @Previewable @State var text: String = ""
    InputField(text: $text, censored: true, placeholder: "placeholder")
}
