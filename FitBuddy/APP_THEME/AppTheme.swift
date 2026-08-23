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

    enum option: String, CaseIterable, Hashable {
        case light = "Light"
        case dark = "Dark"
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
            }
        }
    }
    
    static func from(string: String) -> Theme {
        switch option(rawValue: string) {
        case .light:
            return Theme.light
        case .dark:
            return Theme.dark
        default:
            return Theme.light
        }
    }
    
    // MARK: - Neumorphic Design System Colors (Vector Kit 4786587.jpg)
    static let light = Theme(
        normalMaterial: .systemThinMaterialLight,
        ultraThinMaterial: .systemUltraThinMaterialLight,
        mainColor: Color(red: 0.918, green: 0.933, blue: 0.957), // #EAEEF4 Neumorphic light canvas
        offColor: Color(red: 0.38, green: 0.44, blue: 0.54),     // #61708A Sleek slate contrast
        tabbar: Color(red: 0.922, green: 0.937, blue: 0.961),    // #EBF0F5 Extruded tabbar surface
        text: Color(red: 0.38, green: 0.44, blue: 0.54)          // #61708A High-contrast slate text
    )
    
    static let dark = Theme(
        normalMaterial: .systemThinMaterialDark,
        ultraThinMaterial: .systemUltraThinMaterialDark,
        mainColor: Color(red: 0.125, green: 0.14, blue: 0.17),  // Neumorphic dark canvas
        offColor: Color(red: 0.95, green: 0.96, blue: 0.98),    // Light contrast
        tabbar: Color(red: 0.145, green: 0.165, blue: 0.20),    // Dark extruded tabbar surface
        text: Color(red: 0.95, green: 0.96, blue: 0.98)         // Pure light text
    )
}

// MARK: - Customizable Accent Themes
public enum AccentTheme: String, CaseIterable, Hashable {
    case coral = "Coral"
    case emerald = "Emerald"
    case blue = "Azure"
    case amber = "Amber"
    case purple = "Violet"
    case rose = "Rose"
    
    public var gradient: LinearGradient {
        switch self {
        case .coral:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.44, blue: 0.32), Color(red: 1.0, green: 0.64, blue: 0.36)],
                startPoint: .leading, endPoint: .trailing
            )
        case .emerald:
            return LinearGradient(
                colors: [Color(red: 0.13, green: 0.88, blue: 0.58), Color(red: 0.08, green: 0.78, blue: 0.50)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .blue:
            return LinearGradient(
                colors: [Color(red: 0.22, green: 0.72, blue: 1.0), Color(red: 0.05, green: 0.58, blue: 0.96)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .amber:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.72, blue: 0.12), Color(red: 1.0, green: 0.54, blue: 0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .purple:
            return LinearGradient(
                colors: [Color(red: 0.68, green: 0.45, blue: 0.98), Color(red: 0.52, green: 0.28, blue: 0.88)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .rose:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.38, blue: 0.52), Color(red: 0.95, green: 0.22, blue: 0.42)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
    
    public var primaryColor: Color {
        switch self {
        case .coral: return Color(red: 1.0, green: 0.44, blue: 0.32)
        case .emerald: return Color(red: 0.13, green: 0.88, blue: 0.58)
        case .blue: return Color(red: 0.22, green: 0.72, blue: 1.0)
        case .amber: return Color(red: 1.0, green: 0.72, blue: 0.12)
        case .purple: return Color(red: 0.68, green: 0.45, blue: 0.98)
        case .rose: return Color(red: 1.0, green: 0.38, blue: 0.52)
        }
    }
}

class AppThemeController: ObservableObject {
    @AppStorage("AppTheme") var appTheme: Theme.option = .light {
        didSet {
            main = Theme.from(string: appTheme.rawValue)
        }
    }
    
    @AppStorage("AppAccentTheme") var accentTheme: AccentTheme = .coral
    
    @Published var main: Theme
    
    var accentGradient: LinearGradient {
        accentTheme.gradient
    }
    
    var accentColor: Color {
        accentTheme.primaryColor
    }
    
    init() {
        let storedTheme = UserDefaults.standard.string(forKey: "AppTheme") ?? Theme.option.light.rawValue
        self.main = Theme.from(string: storedTheme)
    }
}
