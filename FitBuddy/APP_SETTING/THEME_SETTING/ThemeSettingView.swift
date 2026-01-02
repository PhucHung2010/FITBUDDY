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
        HStack(spacing: 0) {
            themeToggle
                .padding(.leading, 10)
            
            Canvas {context, size in
                context.addFilter(.alphaThreshold(min: 0.15))
                context.addFilter(.blur(radius: blurRadius >= standardBlurRadius ? standardBlurRadius - (blurRadius - standardBlurRadius) : blurRadius))
                
                context.drawLayer { ctx in
                    if let resolvedImage = context.resolveSymbol(id: 1) {
                        ctx.draw(resolvedImage, at: CGPoint(x: size.width / 1.5, y: size.height / 2), anchor: .center)
                    }
                }
            } symbols: {
                ResolvedImage(currentImage: Theme.themeShape.shape(for: AppTheme.appTheme))
                    .tag(1)
            }
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
            .onTapGesture {
                non_changedPickerImage = true
            }
        }
        .frame(width: UIScreen.main.bounds.width - 30, height: 60)
        .background(BlurRoundedBackground(cornerRadius: 50))
    }
    
    var themeToggle: some View {
        HStack(spacing: 0) {
            ForEach(Theme.option.allCases, id: \.rawValue) { theme in
                Text("\(theme.rawValue)")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(AppTheme.appTheme == theme ? AppTheme.main.mainColor : .Orange)
                    .shadow(radius: 2)
                    .scaleEffect(AppTheme.appTheme == theme ? 1.3 : 1)
                    .padding(.vertical, 10)
                    .frame(width: 100)
                    .background {
                        if AppTheme.appTheme == theme {
                            RoundedRectangle(cornerRadius: 45)
                                .fill(Color.Orange)
                                .matchedGeometryEffect(id: "ActiveTheme", in: animation)
                                .shadow(radius: 4)
                        } else {
                            RoundedRectangle(cornerRadius: 45)
                                .fill(Color.white.opacity(0.0001))
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                            AppTheme.appTheme = theme
                            animationMorph = true
                        }
                    }
            }
        }
        .background(BlurRoundedBackground(cornerRadius: 30))
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





