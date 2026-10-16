//
//  Styles.swift
//  mac-Samsung-Tv-Remote
//
//  Created by Thiago Alessandro  on 16/10/26.
//

import SwiftUI

struct HoverBouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HoverButtonView(configuration: configuration)
    }
}

struct HoverButtonView: View {
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false
    
    var body: some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : (isHovered ? 1.03 : 1.0))
            .brightness(isHovered && !configuration.isPressed ? 0.15 : 0.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

struct ModernCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(Color(white: 0.12).opacity(0.7))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
    }
}
