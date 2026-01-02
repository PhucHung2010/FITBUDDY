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
    
    static let light = Theme(
        normalMaterial: .systemThinMaterialLight,
        ultraThinMaterial: .systemUltraThinMaterialLight,
        mainColor: Color.offWhite,
        offColor: .darkGray3,
        tabbar: .offWhite,
        text: .darkGray3
    )
    
    static let dark = Theme(
        normalMaterial: .systemThinMaterialDark,
        ultraThinMaterial: .systemUltraThinMaterialDark,
        mainColor: Color.darkGray3,
        offColor: Color.offWhite,
        tabbar: Color.darkGray3,
        text: Color.offWhite
    )
}

class AppThemeController: ObservableObject {
    @AppStorage("AppTheme") var appTheme: Theme.option = .light {
        didSet {
            main = Theme.from(string: appTheme.rawValue)
        }
    }
    
    @Published var main: Theme
    
    init() {
        let storedTheme = UserDefaults.standard.string(forKey: "AppTheme") ?? Theme.option.light.rawValue
        self.main = Theme.from(string: storedTheme)
    }
}
