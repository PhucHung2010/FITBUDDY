//
//  MinimalistModifier.swift
//  FitBuddy
//
//  Minimalist design system modifiers
//

import SwiftUI

extension View {
    /// Applies a clean, extruded Neumorphic card background
    @ViewBuilder
    func minimalistBackground(cornerRadius: CGFloat = 24, bgColor: Color? = nil) -> some View {
        if let bgColor = bgColor {
            self.background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(bgColor)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            self.neumorphicCard(cornerRadius: cornerRadius)
        }
    }
}

// MARK: - Neumorphic / Minimalist Stretch Button Style
struct MinimalistStretchButtonStyle: ButtonStyle {
    var scaleRadius: CGFloat = 0.95

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleRadius : 1.0)
            .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
