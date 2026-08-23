//
//  NeumorphicTheme.swift
//  FitBuddy
//
//  Complete Neumorphic Design System inspired by the reference vector kit.
//

import SwiftUI

// MARK: - Neumorphic Palette & Gradients (Exact match for vector kit 4786587.jpg)
public struct NeumorphicColors {
    // Light Mode Canvas & Surfaces (Crisp soft off-white from 4786587.jpg)
    public static let lightBackground = Color(red: 0.918, green: 0.933, blue: 0.957) // #EAEEF4
    public static let lightSurface = Color(red: 0.922, green: 0.937, blue: 0.961)    // #EBF0F5
    public static let lightInset = Color(red: 0.871, green: 0.894, blue: 0.925)      // #DFE4EC
    public static let lightShadowDark = Color(red: 0.635, green: 0.694, blue: 0.776).opacity(0.68) // Slate lowlight
    public static let lightShadowLight = Color.white.opacity(0.98)                    // Pure white highlight
    public static let lightTextPrimary = Color(red: 0.38, green: 0.44, blue: 0.54)   // #61708A Slate primary
    public static let lightTextSecondary = Color(red: 0.58, green: 0.64, blue: 0.73) // #94A3BA Secondary text
    public static let lightTextHeadings = Color(red: 0.22, green: 0.27, blue: 0.35)  // #384559 Bold headings
    
    // Dark Mode Canvas & Surfaces
    public static let darkBackground = Color(red: 0.125, green: 0.14, blue: 0.17)
    public static let darkSurface = Color(red: 0.145, green: 0.165, blue: 0.20)
    public static let darkInset = Color(red: 0.09, green: 0.10, blue: 0.13)
    public static let darkShadowDark = Color.black.opacity(0.75)
    public static let darkShadowLight = Color.white.opacity(0.06)
    public static let darkTextPrimary = Color(red: 0.95, green: 0.96, blue: 0.98)
    public static let darkTextSecondary = Color(red: 0.58, green: 0.64, blue: 0.72)
    public static let darkTextHeadings = Color.white
    
    // Signature 4-Dot Palette from 4786587.jpg
    public static let dotRed = Color(red: 1.0, green: 0.36, blue: 0.36)     // #FF5C5C
    public static let dotYellow = Color(red: 1.0, green: 0.72, blue: 0.12)  // #FFB81E
    public static let dotGreen = Color(red: 0.08, green: 0.82, blue: 0.52)  // #15D185
    public static let dotBlue = Color(red: 0.22, green: 0.71, blue: 1.0)    // #38B5FF
    public static let dotCyan = dotBlue
    
    // Accent Gradients from 4786587.jpg
    public static let coralGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.44, blue: 0.32), Color(red: 1.0, green: 0.64, blue: 0.36)], // Vibrant orange/coral
        startPoint: .leading,
        endPoint: .trailing
    )
    
    public static let greenGradient = LinearGradient(
        colors: [Color(red: 0.13, green: 0.88, blue: 0.58), Color(red: 0.08, green: 0.78, blue: 0.50)], // Emerald green $200 pill
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let blueGradient = LinearGradient(
        colors: [Color(red: 0.22, green: 0.72, blue: 1.0), Color(red: 0.05, green: 0.58, blue: 0.96)], // Sky azure blue
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let orangeGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.42, blue: 0.25), Color(red: 1.0, green: 0.68, blue: 0.32)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Neumorphic Modifiers

public struct NeumorphicCardModifier: ViewModifier {
    @EnvironmentObject var theme: AppThemeController
    var cornerRadius: CGFloat = 24
    var isPressed: Bool = false
    var shadowRadius: CGFloat = 9
    var shadowDistance: CGFloat = 6
    var accentGlow: Color? = nil
    
    public func body(content: Content) -> some View {
        let isLight = theme.appTheme == .light
        let surfaceColor = isLight ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface
        let darkShadow = isLight ? NeumorphicColors.lightShadowDark : NeumorphicColors.darkShadowDark
        let lightShadow = isLight ? NeumorphicColors.lightShadowLight : NeumorphicColors.darkShadowLight
        
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(surfaceColor)
                    .shadow(
                        color: isPressed ? .clear : darkShadow,
                        radius: isPressed ? 2 : shadowRadius,
                        x: isPressed ? 1 : shadowDistance,
                        y: isPressed ? 1 : shadowDistance
                    )
                    .shadow(
                        color: isPressed ? .clear : lightShadow,
                        radius: isPressed ? 2 : shadowRadius,
                        x: isPressed ? -1 : -shadowDistance,
                        y: isPressed ? -1 : -shadowDistance
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                accentGlow ?? (isLight ? Color.white.opacity(0.85) : Color.white.opacity(0.04)),
                                lineWidth: accentGlow != nil ? 1.5 : 0.9
                            )
                    )
            )
    }
}

public struct NeumorphicInsetModifier: ViewModifier {
    @EnvironmentObject var theme: AppThemeController
    var cornerRadius: CGFloat = 20
    var borderColor: Color? = nil
    
    public func body(content: Content) -> some View {
        let isLight = theme.appTheme == .light
        let insetColor = isLight ? NeumorphicColors.lightInset : NeumorphicColors.darkInset
        
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(insetColor)
                    .overlay(
                        // Inner top-left debossed shadow
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                borderColor ?? (isLight ? Color(red: 0.60, green: 0.66, blue: 0.74).opacity(0.45) : Color.black.opacity(0.5)),
                                lineWidth: 1.5
                            )
                            .shadow(color: isLight ? Color(red: 0.55, green: 0.62, blue: 0.72).opacity(0.45) : Color.black.opacity(0.7), radius: 3, x: 2, y: 2)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    )
                    .overlay(
                        // Inner bottom-right highlight reflection
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                isLight ? Color.white.opacity(0.85) : Color.white.opacity(0.06),
                                lineWidth: 1.2
                            )
                            .offset(x: 1.5, y: 1.5)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    )
            )
    }
}

public struct NeumorphicCircleModifier: ViewModifier {
    @EnvironmentObject var theme: AppThemeController
    var isPressed: Bool = false
    var shadowRadius: CGFloat = 8
    var shadowDistance: CGFloat = 5
    var accentGlow: Color? = nil
    
    public func body(content: Content) -> some View {
        let isLight = theme.appTheme == .light
        let surfaceColor = isLight ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface
        let darkShadow = isLight ? NeumorphicColors.lightShadowDark : NeumorphicColors.darkShadowDark
        let lightShadow = isLight ? NeumorphicColors.lightShadowLight : NeumorphicColors.darkShadowLight
        
        content
            .background(
                Circle()
                    .fill(surfaceColor)
                    .shadow(
                        color: isPressed ? .clear : darkShadow,
                        radius: isPressed ? 2 : shadowRadius,
                        x: isPressed ? 1 : shadowDistance,
                        y: isPressed ? 1 : shadowDistance
                    )
                    .shadow(
                        color: isPressed ? .clear : lightShadow,
                        radius: isPressed ? 2 : shadowRadius,
                        x: isPressed ? -1 : -shadowDistance,
                        y: isPressed ? -1 : -shadowDistance
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                accentGlow ?? (isLight ? Color.white.opacity(0.85) : Color.white.opacity(0.05)),
                                lineWidth: accentGlow != nil ? 1.5 : 0.9
                            )
                    )
            )
    }
}

public struct NeumorphicPillModifier: ViewModifier {
    @EnvironmentObject var theme: AppThemeController
    var gradient: LinearGradient? = nil
    var isPressed: Bool = false
    
    public func body(content: Content) -> some View {
        let isLight = theme.appTheme == .light
        let darkShadow = isLight ? NeumorphicColors.lightShadowDark : NeumorphicColors.darkShadowDark
        let lightShadow = isLight ? NeumorphicColors.lightShadowLight : NeumorphicColors.darkShadowLight
        let surface = isLight ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface
        
        content
            .background(
                Capsule()
                    .fill(gradient ?? LinearGradient(colors: [surface, surface], startPoint: .top, endPoint: .bottom))
                    .shadow(
                        color: isPressed ? .clear : (gradient != nil ? Color.black.opacity(0.16) : darkShadow),
                        radius: isPressed ? 2 : 7,
                        x: isPressed ? 1 : 4,
                        y: isPressed ? 1 : 4
                    )
                    .shadow(
                        color: isPressed ? .clear : (gradient != nil ? Color.white.opacity(0.3) : lightShadow),
                        radius: isPressed ? 2 : 7,
                        x: isPressed ? -1 : -4,
                        y: isPressed ? -1 : -4
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                gradient != nil ? Color.white.opacity(0.3) : (isLight ? Color.white.opacity(0.85) : Color.white.opacity(0.06)),
                                lineWidth: 0.9
                            )
                    )
            )
    }
}

// MARK: - View Extensions
public extension View {
    func neumorphicCard(
        cornerRadius: CGFloat = 24,
        isPressed: Bool = false,
        shadowRadius: CGFloat = 8,
        shadowDistance: CGFloat = 5,
        accentGlow: Color? = nil
    ) -> some View {
        self.modifier(NeumorphicCardModifier(
            cornerRadius: cornerRadius,
            isPressed: isPressed,
            shadowRadius: shadowRadius,
            shadowDistance: shadowDistance,
            accentGlow: accentGlow
        ))
    }
    
    func neumorphicInset(
        cornerRadius: CGFloat = 20,
        borderColor: Color? = nil
    ) -> some View {
        self.modifier(NeumorphicInsetModifier(
            cornerRadius: cornerRadius,
            borderColor: borderColor
        ))
    }
    
    func neumorphicCircle(
        isPressed: Bool = false,
        shadowRadius: CGFloat = 6,
        shadowDistance: CGFloat = 5,
        accentGlow: Color? = nil
    ) -> some View {
        self.modifier(NeumorphicCircleModifier(
            isPressed: isPressed,
            shadowRadius: shadowRadius,
            shadowDistance: shadowDistance,
            accentGlow: accentGlow
        ))
    }
    
    func neumorphicPill(
        gradient: LinearGradient? = nil,
        isPressed: Bool = false
    ) -> some View {
        self.modifier(NeumorphicPillModifier(
            gradient: gradient,
            isPressed: isPressed
        ))
    }
}

// MARK: - 4-Dot Signature Indicator View (from 4786587.jpg)
public struct NeumorphicIndicatorDots: View {
    public var dotSize: CGFloat = 6
    public var spacing: CGFloat = 5
    
    public init(dotSize: CGFloat = 6, spacing: CGFloat = 5) {
        self.dotSize = dotSize
        self.spacing = spacing
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            Circle().fill(NeumorphicColors.dotRed).frame(width: dotSize, height: dotSize)
            Circle().fill(NeumorphicColors.dotYellow).frame(width: dotSize, height: dotSize)
            Circle().fill(NeumorphicColors.dotGreen).frame(width: dotSize, height: dotSize)
            Circle().fill(NeumorphicColors.dotBlue).frame(width: dotSize, height: dotSize)
        }
    }
}

// MARK: - Tactile Neumorphic Button Style
public struct NeumorphicStretchButtonStyle: ButtonStyle {
    public var scaleRadius: CGFloat = 0.96
    public var cornerRadius: CGFloat = 22
    public var accentGlow: Color? = nil
    
    public init(scaleRadius: CGFloat = 0.96, cornerRadius: CGFloat = 22, accentGlow: Color? = nil) {
        self.scaleRadius = scaleRadius
        self.cornerRadius = cornerRadius
        self.accentGlow = accentGlow
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleRadius : 1.0)
            .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Rotary Neumorphic Knob Dial (Central element in 4786587.jpg)
public struct NeumorphicKnobView<CenterContent: View>: View {
    @EnvironmentObject var theme: AppThemeController
    public var size: CGFloat = 160
    public var progress: Double = 0.75
    public var centerContent: CenterContent
    
    public init(size: CGFloat = 160, progress: Double = 0.75, @ViewBuilder centerContent: () -> CenterContent) {
        self.size = size
        self.progress = progress
        self.centerContent = centerContent()
    }
    
    public var body: some View {
        ZStack {
            // Outer Ring Track with Dots
            ForEach(0..<24) { i in
                let angle = Double(i) * (360.0 / 24.0) - 90
                let isFilled = Double(i) / 24.0 <= progress
                let dotColor: Color = {
                    if !isFilled { return theme.main.text.opacity(0.18) }
                    let ratio = Double(i) / 24.0
                    if ratio < 0.25 { return NeumorphicColors.dotRed }
                    if ratio < 0.50 { return NeumorphicColors.dotYellow }
                    if ratio < 0.75 { return NeumorphicColors.dotGreen }
                    return NeumorphicColors.dotBlue
                }()
                
                Circle()
                    .fill(dotColor)
                    .frame(width: i % 6 == 0 ? 6 : 4, height: i % 6 == 0 ? 6 : 4)
                    .offset(y: -(size / 2 + 16))
                    .rotationEffect(.degrees(angle))
            }
            
            // Outer Extruded Bezel
            Circle()
                .fill(theme.appTheme == .light ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface)
                .frame(width: size, height: size)
                .neumorphicCircle(shadowRadius: 10, shadowDistance: 7)
            
            // Inner Inset Well
            Circle()
                .fill(theme.appTheme == .light ? NeumorphicColors.lightInset : NeumorphicColors.darkInset)
                .frame(width: size * 0.82, height: size * 0.82)
                .neumorphicInset(cornerRadius: size * 0.41)
            
            // Inner Raised Knob Hub
            Circle()
                .fill(theme.appTheme == .light ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface)
                .frame(width: size * 0.68, height: size * 0.68)
                .neumorphicCircle(shadowRadius: 6, shadowDistance: 4)
                .overlay(
                    // 4 Axis Indicator Dots on Knob
                    VStack {
                        Circle().fill(NeumorphicColors.dotGreen).frame(width: 4, height: 4)
                        Spacer()
                        HStack {
                            Circle().fill(NeumorphicColors.dotRed).frame(width: 4, height: 4)
                            Spacer()
                            Circle().fill(NeumorphicColors.dotBlue).frame(width: 4, height: 4)
                        }
                        Spacer()
                        Circle().fill(NeumorphicColors.dotYellow).frame(width: 4, height: 4)
                    }
                    .frame(width: size * 0.52, height: size * 0.52)
                )
            
            // Center Custom Content
            centerContent
        }
        .frame(width: size + 40, height: size + 40)
    }
}
