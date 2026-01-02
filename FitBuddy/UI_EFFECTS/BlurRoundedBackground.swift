//
//  BlurRoundedBackground.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 22/7/25.
//

import SwiftUI

struct BlurRoundedBackground: View {
    @EnvironmentObject var theme: AppThemeController
    var cornerRadius: CGFloat = 20
    var shadowRadius: CGFloat = 4
    var style: UIBlurEffect.Style = .systemUltraThinMaterialLight
    var usingLocal: Bool
    
    init(cornerRadius: CGFloat = 20,
         shadowRadius: CGFloat = 4,
         style: UIBlurEffect.Style = .systemUltraThinMaterialLight,
         usingLocal: Bool = false) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.style = style
        self.usingLocal = usingLocal
    }

    var body: some View {
        BlurView(style: usingLocal ? style : theme.main.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(radius: shadowRadius)
    }
}
