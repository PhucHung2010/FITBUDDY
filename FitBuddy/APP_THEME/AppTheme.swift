//
//  AppTheme.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 6/8/25.
//

import SwiftUI

struct Theme {
    let normalMaterial: UIBlurEffect.Style
    let ultraThinMaterial: UIBlurEffect.Style
    let mainColor: Color
    let offColor: Color
    let tabbar: Color
    let text: Color
    let accent: Color

    enum option: String, CaseIterable, Hashable {
        case light = "Light"
        case dark = "Dark"
        case cosmic = "Cosmic"
        case sunset = "Sunset"
    }
    enum themeShape: String, CaseIterable {
        case sun = "sun.max.fill"
        case moon = "moon.fill"
        
        static func shape(for theme: Theme.option) -> String {
            switch theme {
            case .light:
                return themeShape.sun.rawValue
            case .dark:
                return themeShape.moon.rawValue
            case .cosmic:
                return "sparkles"
            case .sunset:
                return "sunset.fill"
            }
        }
    }
    
    static func from(string: String) -> Theme {
        switch option(rawValue: string) {
        case .light:
            return Theme.light
        case .dark:
            return Theme.dark
        case .cosmic:
            return Theme.cosmic
        case .sunset:
            return Theme.sunset
        default:
            return Theme.light
        }
    }
    
    static let light = Theme(
        normalMaterial: .systemThinMaterialLight,
        ultraThinMaterial: .systemUltraThinMaterialLight,
        mainColor: Color.offWhite,
        offColor: .darkGray3,
        tabbar: Color(red: 200 / 255, green: 205 / 255, blue: 225 / 255),  // Cosmic silver tabbar
        text: Color(red: 35 / 255, green: 30 / 255, blue: 55 / 255),        // Deep space text
        accent: Color(red: 0 / 255, green: 200 / 255, blue: 255 / 255)     // Electric Cyan
    )
    
    static let dark = Theme(
        normalMaterial: .systemThinMaterialDark,
        ultraThinMaterial: .systemUltraThinMaterialDark,
        mainColor: Color(red: 18 / 255, green: 15 / 255, blue: 35 / 255),  // Deep space
        offColor: Color(red: 210 / 255, green: 215 / 255, blue: 235 / 255), // Starlight
        tabbar: Color(red: 12 / 255, green: 10 / 255, blue: 28 / 255),     // Void tabbar
        text: Color(red: 210 / 255, green: 215 / 255, blue: 235 / 255),     // Starlight text
        accent: Color(red: 0 / 255, green: 200 / 255, blue: 255 / 255)     // Electric Cyan
    )
    
    static let cosmic = Theme(
        normalMaterial: .systemThinMaterialDark,
        ultraThinMaterial: .systemUltraThinMaterialDark,
        mainColor: Color(red: 25 / 255, green: 10 / 255, blue: 45 / 255),  // Deep Violet
        offColor: Color(red: 0 / 255, green: 230 / 255, blue: 255 / 255),  // Cyan Glow
        tabbar: Color(red: 15 / 255, green: 5 / 255, blue: 30 / 255),       // Darker Violet
        text: .white,
        accent: Color(red: 0 / 255, green: 200 / 255, blue: 255 / 255)     // Electric Cyan
    )
    
    static let sunset = Theme(
        normalMaterial: .systemThinMaterialDark,
        ultraThinMaterial: .systemUltraThinMaterialDark,
        mainColor: Color(red: 45 / 255, green: 5 / 255, blue: 15 / 255),   // Black Cherry
        offColor: Color(red: 255 / 255, green: 160 / 255, blue: 0 / 255),  // Vivid Orange
        tabbar: Color(red: 30 / 255, green: 5 / 255, blue: 10 / 255),       // Shadow Red
        text: .white,
        accent: Color(red: 255 / 255, green: 160 / 255, blue: 0 / 255)     // Vivid Orange
    )
}

class AppThemeController: ObservableObject {
    @AppStorage("AppTheme") var appTheme: Theme.option = .light {
        didSet {
            updateMainTheme()
        }
    }
    
    @AppStorage("CustomTextColor") var customTextColor: String = "" {
        didSet { updateMainTheme() }
    }
    
    @AppStorage("CustomAccentColor") var customAccentColor: String = "" {
        didSet { updateMainTheme() }
    }
    
    @Published var main: Theme
    
    init() {
        let storedTheme = UserDefaults.standard.string(forKey: "AppTheme") ?? Theme.option.light.rawValue
        let baseTheme = Theme.from(string: storedTheme)
        
        // Initial build with potential custom overrides
        let textColorOverride = UserDefaults.standard.string(forKey: "CustomTextColor") ?? ""
        let accentColorOverride = UserDefaults.standard.string(forKey: "CustomAccentColor") ?? ""
        
        self.main = Theme(
            normalMaterial: baseTheme.normalMaterial,
            ultraThinMaterial: baseTheme.ultraThinMaterial,
            mainColor: baseTheme.mainColor,
            offColor: baseTheme.offColor,
            tabbar: baseTheme.tabbar,
            text: textColorOverride.isEmpty ? baseTheme.text : Color(hex: textColorOverride),
            accent: accentColorOverride.isEmpty ? baseTheme.accent : Color(hex: accentColorOverride)
        )
    }
    
    private func updateMainTheme() {
        let baseTheme = Theme.from(string: appTheme.rawValue)
        main = Theme(
            normalMaterial: baseTheme.normalMaterial,
            ultraThinMaterial: baseTheme.ultraThinMaterial,
            mainColor: baseTheme.mainColor,
            offColor: baseTheme.offColor,
            tabbar: baseTheme.tabbar,
            text: customTextColor.isEmpty ? baseTheme.text : Color(hex: customTextColor),
            accent: customAccentColor.isEmpty ? baseTheme.accent : Color(hex: customAccentColor)
        )
    }
}
