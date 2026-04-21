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
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Theme.option.allCases, id: \.rawValue) { theme in
                        ThemeButton(theme: theme)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            
            HStack {
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
                        .tag(1)
                }
                .frame(width: 100, height: 100)
                .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
                    handleAnimation()
                }
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .background(BlurRoundedBackground(cornerRadius: 30))
        .padding(.horizontal, 15)
        
        VStack(spacing: 20) {
            Text("Customize Colors")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(AppTheme.main.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Text Color")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.main.text)
                Spacer()
                ColorPicker("", selection: Binding(get: {
                    AppTheme.customTextColor.isEmpty ? AppTheme.main.text : Color(hex: AppTheme.customTextColor)
                }, set: { newColor in
                    AppTheme.customTextColor = newColor.toHex() ?? ""
                }))
                .labelsHidden()
            }
            
            HStack {
                Text("Icon & Accent Color")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.main.text)
                Spacer()
                ColorPicker("", selection: Binding(get: {
                    AppTheme.customAccentColor.isEmpty ? AppTheme.main.accent : Color(hex: AppTheme.customAccentColor)
                }, set: { newColor in
                    AppTheme.customAccentColor = newColor.toHex() ?? ""
                }))
                .labelsHidden()
            }
            
            Button(action: {
                withAnimation {
                    AppTheme.customTextColor = ""
                    AppTheme.customAccentColor = ""
                }
            }) {
                Text("Reset to Theme Default")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.main.accent)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(AppTheme.main.accent.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding(20)
        .background(BlurRoundedBackground(cornerRadius: 30))
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    func ThemeButton(theme: Theme.option) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(getThemeColor(theme))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.appTheme == theme ? AppTheme.main.accent : Color.clear, lineWidth: 3)
                    )
                    .shadow(color: getThemeColor(theme).opacity(0.3), radius: 5, x: 0, y: 5)
                
                if AppTheme.appTheme == theme {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Text(theme.rawValue)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.appTheme == theme ? AppTheme.main.accent : AppTheme.main.text.opacity(0.6))
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                AppTheme.appTheme = theme
                animationMorph = true
            }
        }
    }
    
    private func getThemeColor(_ theme: Theme.option) -> Color {
        switch theme {
        case .light: return Color.white
        case .dark: return Color(red: 18/255, green: 15/255, blue: 35/255)
        case .cosmic: return Color(red: 35/255, green: 15/255, blue: 60/255)
        case .sunset: return Color(red: 65/255, green: 10/255, blue: 25/255)
        }
    }
    
    private func handleAnimation() {
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
        } else {
            if blurRadius <=  2*standardBlurRadius {
                blurRadius += blurTime
                if blurRadius.rounded() >=  2*standardBlurRadius {
                    animationMorph = false
                    non_changedPickerImage = false
                    blurRadius = 0
                }
            }
        }
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





extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if a != 1.0 {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(a * 255), lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
