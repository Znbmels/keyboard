//
//  Extensions.swift
//  Keyboard
//
//  Created by Zainab on 19.06.2025.
//

import SwiftUI

// MARK: - Font Extensions
extension Font {
    static func amiriQuran(size: CGFloat) -> Font {
        return Font.custom("AmiriQuran-Regular", size: size)
    }
    
    static func amiriQuranBold(size: CGFloat) -> Font {
        return Font.custom("AmiriQuran-Bold", size: size)
    }
}

// MARK: - Text Extensions
extension Text {
    func amiriQuranFont(size: CGFloat) -> Text {
        return self.font(.custom("AmiriQuran-Regular", size: size))
    }
    
    func amiriQuranBoldFont(size: CGFloat) -> Text {
        return self.font(.custom("AmiriQuran-Bold", size: size))
    }
}

// MARK: - Color Extensions
extension Color {
    static let islamicGreen = Color(red: 0.0, green: 0.5, blue: 0.0)
    static let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.05)
    static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.1)
}

// MARK: - View Extensions
extension View {
    func islamicCardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    func islamicButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
