//
//  Dark_light_switchMode.swift
//  CALCULATOR
//
//  Created by Hung Nguyen on 15/08/2024.
//

import SwiftUI
import UIKit
import Foundation



struct ResolvedImage: View {
    let currentImage: String
    var body: some View {
        Image(systemName: currentImage)
            .font(.system(size: 50))
            .animation(.easeInOut, value: currentImage)
    }
}



struct ThemeSettingView: View {
    @EnvironmentObject var AppTheme: AppThemeController
    let standardBlurRadius: CGFloat = 10
    let blurTime: CGFloat = 0.5
    @Namespace private var animation

    @State var blurRadius: CGFloat = 0
    @State var animationMorph: Bool = false
    @State var non_changedPickerImage = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Mode Toggle (Light / Dark)
            HStack(spacing: 12) {
                themeToggle
                    .padding(.leading, 6)
                
                Spacer()
                
                Canvas { context, size in
                    context.addFilter(.alphaThreshold(min: 0.15))
                    context.addFilter(.blur(radius: blurRadius >= standardBlurRadius ? standardBlurRadius - (blurRadius - standardBlurRadius) : blurRadius))
                    
                    context.drawLayer { ctx in
                        if let resolvedImage = context.resolveSymbol(id: 1) {
                            ctx.draw(resolvedImage, at: CGPoint(x: size.width / 2, y: size.height / 2), anchor: .center)
                        }
                    }
                } symbols: {
                    ResolvedImage(currentImage: Theme.themeShape.shape(for: AppTheme.appTheme))
                        .foregroundColor(AppTheme.accentColor)
                        .tag(1)
                }
                .frame(width: 50, height: 50)
                .padding(.trailing, 10)
                .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
                    if non_changedPickerImage == false {
                        if animationMorph {
                            if blurRadius <= 2*standardBlurRadius {
                                blurRadius += blurTime
                                if blurRadius.rounded() >= 2*standardBlurRadius {
                                    animationMorph = false
                                    blurRadius = 0
                                }
                            }
                        }
                    }
                    else {
                        if blurRadius <= 2*standardBlurRadius {
                            blurRadius += blurTime
                            if blurRadius.rounded() >= 2*standardBlurRadius {
                                animationMorph = false
                                non_changedPickerImage = false
                                blurRadius = 0
                            }
                        }
                    }
                }
                .onTapGesture {
                    non_changedPickerImage = true
                }
            }
            .frame(width: UIScreen.main.bounds.width - 32, height: 66)
            .padding(.horizontal, 10)
            .neumorphicCard(cornerRadius: 28)
            
            // Accent Color Palette Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Accent Color")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.main.text)
                    
                    Spacer()
                    
                    Text(AppTheme.accentTheme.rawValue)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.accentColor)
                }
                .padding(.horizontal, 4)
                
                // Color Swatches Row
                HStack(spacing: 0) {
                    ForEach(AccentTheme.allCases, id: \.self) { accent in
                        let isSelected = AppTheme.accentTheme == accent
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                AppTheme.accentTheme = accent
                            }
                        }) {
                            ZStack {
                                if isSelected {
                                    Circle()
                                        .stroke(accent.primaryColor, lineWidth: 2.5)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: accent.primaryColor.opacity(0.4), radius: 4)
                                }
                                
                                Circle()
                                    .fill(accent.gradient)
                                    .frame(width: 32, height: 32)
                                    .shadow(color: Color.black.opacity(0.18), radius: 3, y: 1.5)
                                    .overlay {
                                        if isSelected {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 13, weight: .black))
                                                .foregroundColor(.white)
                                        }
                                    }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.88))
                    }
                }
                .padding(.vertical, 8)
                .neumorphicInset(cornerRadius: 20)
            }
            .padding(16)
            .frame(width: UIScreen.main.bounds.width - 32)
            .neumorphicCard(cornerRadius: 26)
        }
    }
    
    var themeToggle: some View {
        HStack(spacing: 4) {
            ForEach(Theme.option.allCases, id: \.rawValue) { theme in
                let isSelected = AppTheme.appTheme == theme
                Text("\(theme.rawValue)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : AppTheme.main.text.opacity(0.55))
                    .padding(.vertical, 8)
                    .frame(width: 90)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(AppTheme.accentGradient)
                                .matchedGeometryEffect(id: "ActiveTheme", in: animation)
                                .shadow(color: Color.black.opacity(0.18), radius: 4, y: 2)
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            AppTheme.appTheme = theme
                            animationMorph = true
                        }
                    }
            }
        }
        .padding(4)
        .neumorphicInset(cornerRadius: 22)
    }
}

struct ThemeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground()
            ThemeSettingView()
        }
        .environmentObject(AppThemeController())
    }
}





