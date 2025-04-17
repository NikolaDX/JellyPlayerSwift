//
//  ConditionalButton.swift
//  JellyPlayerSwift
//
//  Created by Nikola Ristic on 4/17/25.
//

import SwiftUI

struct ConditionalIconButton: View {
    private var condition: Bool
    private var trueLabel: Image
    private var falseLabel: Image
    private var action: () -> Void
    
    init(condition: Bool, trueLabel: Image, falseLabel: Image, action: @escaping () -> Void) {
        self.condition = condition
        self.trueLabel = trueLabel
        self.falseLabel = falseLabel
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            condition ? trueLabel : falseLabel
        }
    }
}

#Preview {
    ConditionalIconButton(condition: true, trueLabel: Image(systemName: "photo.fill"), falseLabel: Image(systemName: "photo.fill")) { }
}
