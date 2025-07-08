//
//  SearchBar.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    init(text: Binding<String>, placeholder: String = "Search...") {
        self._text = text
        self.placeholder = placeholder
    }
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass.circle.fill")
                .foregroundColor(.islamicGreen)

            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .font(.body)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.square.fill")
                        .foregroundColor(.islamicGreen)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}
