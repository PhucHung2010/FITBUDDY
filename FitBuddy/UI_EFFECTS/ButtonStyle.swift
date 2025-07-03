//
//  ButtonStyle.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 15/06/2025.
//

import Foundation
import SwiftUI

struct ScaledButtonStyle: ButtonStyle {
    var scaleRadius: CGFloat
    var animationDuration: CGFloat
    init(scaleRadius: CGFloat = 3.5, animationDuration: CGFloat = 0.3) {
        self.scaleRadius = scaleRadius
        self.animationDuration = animationDuration
    }
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.2 : 1)
            .scaleEffect(configuration.isPressed ? scaleRadius : 1)
            .animation(.easeInOut(duration: animationDuration), value: configuration.isPressed)
    }
}

struct ScaledButtonStyle_OffColorText: ButtonStyle {
    var text: String
    var originColor: Color
    var offColor: Color
    var textFont: Double
    var scaleRadius: CGFloat
    var animationDuration: CGFloat
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            Text("\(text)")
            .font(.system(size: textFont, weight: .bold, design: .default))
            .foregroundColor(configuration.isPressed ? originColor : offColor)
            .lineLimit(1)
            .shadow(radius: 3)
            .frame(width: 100, height: 45)
            .background {
                if configuration.isPressed {
                    offColor
                        .opacity(0.85)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(radius: 6)
                } else {
                    originColor
                        .opacity(0.85)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(radius: 6)
                }
            }
            .minimumScaleFactor(0.3)
            .scaleEffect(configuration.isPressed ? scaleRadius : 1)
            .animation(.easeInOut(duration: animationDuration), value: configuration.isPressed)
    }
}


struct PickerButton: View {
    let title: Int
    let systemImage: String?
    
    @GestureState private var isPressed = false

    init(title: Int, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }
    
    

    var body: some View {
        Group {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 40, weight: .black, design: .default))
                    .foregroundColor(.lightOffWhite)
                    .shadow(radius: 3)
                    .background {
                        Color.Orange
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                            .frame(width: UIScreen.main.bounds.width / 4, height: 50)
                    }
            } else {
                Text("\(title)")
                    .font(.system(size: 40, weight: .black, design: .default))
                    .foregroundColor(.Orange)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width / 4, height: 50)
                    .background {
                        BlurView(style: .systemUltraThinMaterialLight)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    }
                    .minimumScaleFactor(0.2)
            }
        }
    }
}


struct NumpadButton: View {
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
                    .font(.system(size: 40, weight: .black, design: .default))
                    .foregroundColor(.lightOffWhite)
                    .shadow(radius: 3)
                    .background {
                        Color.Orange
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                            .frame(width: UIScreen.main.bounds.width / 4, height: 50)
                    }
                    
            } else {
                Text(title)
                    .font(.system(size: 50, weight: .black, design: .default))
                    .foregroundColor(.Orange)
                    .shadow(radius: 3)
                    .background {
                        BlurView(style: .systemUltraThinMaterialLight)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 6)
                            .frame(width: UIScreen.main.bounds.width / 4, height: 50)
                    }
                    
            }
                
        }
        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.8, animationDuration: 0.15))
    }
}
