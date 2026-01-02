//
//  textFieldModifier.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 26/06/2025.
//

import Foundation
import SwiftUI

struct customViewModifier: ViewModifier {
    @EnvironmentObject var theme: AppThemeController
    var startColor: Color
    var endColor: Color
    var textColor: Color
    var roundedCornes: CGFloat

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: 40)
            .background(
                BlurView(style: theme.main.ultraThinMaterial)
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


struct customViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
            .environmentObject(TabViewController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
