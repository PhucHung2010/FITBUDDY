//
//  ButtonStyle.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 15/06/2025.
//

import Foundation
import SwiftUI

struct ScaledButtonStyle: ButtonStyle {
    var scaleRadius: CGFloat = 0.95
    var animationDuration: CGFloat = 0.2
    
    init(scaleRadius: CGFloat = 0.95, animationDuration: CGFloat = 0.2) {
        self.scaleRadius = scaleRadius
        self.animationDuration = animationDuration
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleRadius : 1)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ScaledButtonStyle_OffColorText: ButtonStyle {
    var text: String
    var originColor: Color
    var offColor: Color
    var textFont: Double
    var scaleRadius: CGFloat = 0.92
    var animationDuration: CGFloat = 0.2
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
        Text("\(text)")
            .font(.system(size: textFont, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .lineLimit(1)
            .frame(width: 100, height: 48)
            .background(
                Capsule()
                    .fill(configuration.isPressed ? NeumorphicColors.coralGradient : NeumorphicColors.greenGradient)
                    .shadow(color: Color.black.opacity(configuration.isPressed ? 0.1 : 0.25), radius: configuration.isPressed ? 2 : 6, y: configuration.isPressed ? 1 : 4)
            )
            .minimumScaleFactor(0.4)
            .scaleEffect(configuration.isPressed ? scaleRadius : 1)
            .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct PickerButton: View {
    @EnvironmentObject var theme: AppThemeController
    let title: Int
    let systemImage: String?

    init(title: Int, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }

    var body: some View {
        Group {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width / 4, height: 50)
                    .background(
                        Capsule()
                            .fill(NeumorphicColors.coralGradient)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, y: 3)
                    )
            } else {
                Text("\(title)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(theme.main.text)
                    .frame(width: UIScreen.main.bounds.width / 4, height: 50)
                    .neumorphicCard(cornerRadius: 25)
                    .minimumScaleFactor(0.3)
            }
        }
    }
}

struct NumpadButton: View {
    @EnvironmentObject var theme: AppThemeController
    let title: String
    let systemImage: String?
    let action: () -> Void
    
    init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            if let systemImage = systemImage {
                Image(systemName: "\(systemImage)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width / 4, height: 52)
                    .background(
                        Capsule()
                            .fill(NeumorphicColors.coralGradient)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, y: 3)
                    )
            } else {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
                    .frame(width: UIScreen.main.bounds.width / 4, height: 52)
                    .neumorphicCard(cornerRadius: 18)
            }
        }
        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.92, animationDuration: 0.15))
    }
}
