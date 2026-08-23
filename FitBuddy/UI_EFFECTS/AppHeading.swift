//
//  AppHeading.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 6/8/25.
//

import SwiftUI

/// Neumorphic page heading — used as the top App Bar on each tab.
/// Designed to be placed at the top of a ScrollView with `.padding(.horizontal)`.
struct AppHeadingView: View {
    let title: String
    @EnvironmentObject var theme: AppThemeController

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(theme.main.text)
            
            Spacer()
            
            NeumorphicIndicatorDots(dotSize: 6, spacing: 5)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .neumorphicInset(cornerRadius: 12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .neumorphicCard(cornerRadius: 24)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct AppHeadingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground()
            VStack {
                AppHeadingView(title: "FitBuddy")
                    .environmentObject(AppThemeController())
                Spacer()
            }
        }
    }
}
