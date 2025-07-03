//
//  textFieldModifier.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 26/06/2025.
//

import Foundation
import SwiftUI

struct customViewModifier: ViewModifier {
    var startColor: Color
    var endColor: Color
    var textColor: Color
    var roundedCornes: CGFloat

    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                BlurView(style: .systemUltraThinMaterial)
            )
            .cornerRadius(roundedCornes)
            .padding(3)
            .foregroundColor(textColor)
            .font(.system(size: 20, weight: .heavy))
            .shadow(color: .black.opacity(0.5),
                    radius: 2,
                    x: 2, y: 2)
            .shadow(color: .black.opacity(0.2),
                    radius: 2,
                    x: -1, y: -1)
    }
}
