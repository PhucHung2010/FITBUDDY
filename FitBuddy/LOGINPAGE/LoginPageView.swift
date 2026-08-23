//
//  LoginPageView.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//  Motivational Neumorphic Login Experience
//

import SwiftUI

struct MotivationalQuote {
    let quote: String
    let author: String
    let icon: String
}

struct LoginPageView: View {
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var theme: AppThemeController
    
    // Animations
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.6
    @State private var orbitRotation: Double = 0
    @State private var floatOffset: CGFloat = 0
    @State private var currentQuoteIndex = 0
    @State private var quoteFade = true
    
    // Ambient orb offsets
    @State private var orb1Offset: CGSize = .init(width: -60, height: -120)
    @State private var orb2Offset: CGSize = .init(width: 80, height: 160)
    
    // Motivational Quotes
    private let quotes: [MotivationalQuote] = [
        MotivationalQuote(quote: "Transform your sweat into strength.", author: "Daily Push", icon: "flame.fill"),
        MotivationalQuote(quote: "Every single rep counts towards the new you.", author: "Consistency", icon: "bolt.heart.fill"),
        MotivationalQuote(quote: "Your only limit is the one you believe.", author: "Mindset", icon: "sparkles"),
        MotivationalQuote(quote: "Discipline beats motivation every day.", author: "Focus", icon: "trophy.fill"),
        MotivationalQuote(quote: "Master your form, unlock your potential.", author: "AI Trainer", icon: "figure.strengthtraining.traditional")
    ]
    
    // Quote rotation timer
    let timer = Timer.publish(every: 4.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            // Ambient Floating Energy Glows
            ambientGlowLayer
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header & Dots
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(theme.accentColor)
                        Text("FITBUDDY AI")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(theme.accentColor)
                            .tracking(1.5)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .neumorphicInset(cornerRadius: 14)
                    
                    Spacer()
                    
                    NeumorphicIndicatorDots(dotSize: 6, spacing: 5)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer(minLength: 12)
                
                // MARK: - Animated Energy Hub (Logo with Ripple Waves)
                energyHubSection
                    .offset(y: floatOffset)
                
                Spacer(minLength: 16)
                
                // MARK: - Rotating Motivational Affirmation Card
                motivationalQuoteCard
                    .padding(.horizontal, 24)
                
                Spacer(minLength: 16)
                
                // MARK: - Live Fitness Ticker Pills
                featureTickerRow
                    .padding(.horizontal, 20)
                
                Spacer(minLength: 20)
                
                // MARK: - Sign-In Action Area
                actionSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            startContinuousAnimations()
        }
        .onReceive(timer) { _ in
            rotateQuote()
        }
    }
    
    // MARK: - Ambient Glow Layer
    private var ambientGlowLayer: some View {
        ZStack {
            Circle()
                .fill(theme.accentColor.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 60)
                .offset(orb1Offset)
            
            Circle()
                .fill(NeumorphicColors.dotCyan.opacity(0.10))
                .frame(width: 220, height: 220)
                .blur(radius: 50)
                .offset(orb2Offset)
        }
    }
    
    // MARK: - Energy Hub (Logo with concentric ripple waves)
    private var energyHubSection: some View {
        VStack(spacing: 20) {
            ZStack {
                // Expanding Outer Energy Waves
                Circle()
                    .stroke(theme.accentColor.opacity(0.25), lineWidth: 2)
                    .frame(width: 170, height: 170)
                    .scaleEffect(pulseScale * 1.08)
                    .opacity(pulseOpacity)
                
                Circle()
                    .stroke(theme.accentColor.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulseScale * 1.16)
                    .opacity(max(0, pulseOpacity - 0.2))
                
                // Outer Neumorphic Disc
                Circle()
                    .fill(theme.appTheme == .light ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface)
                    .frame(width: 130, height: 130)
                    .neumorphicCircle(shadowRadius: 14, shadowDistance: 8)
                
                // Inner Debossed Track
                Circle()
                    .fill(theme.appTheme == .light ? NeumorphicColors.lightInset : NeumorphicColors.darkInset)
                    .frame(width: 102, height: 102)
                    .neumorphicInset(cornerRadius: 51)
                
                // Core Gradient Pulse Disc
                Circle()
                    .fill(theme.accentGradient)
                    .frame(width: 76, height: 76)
                    .scaleEffect(pulseScale)
                    .shadow(color: theme.accentColor.opacity(0.4), radius: 10, y: 4)
                
                // Center Icon with 3D Tilt
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 34, weight: .black))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isAnimating ? 6 : -6))
                
                // Orbiting Energy Spark
                Circle()
                    .fill(NeumorphicColors.dotYellow)
                    .frame(width: 8, height: 8)
                    .shadow(color: NeumorphicColors.dotYellow, radius: 4)
                    .offset(x: 58)
                    .rotationEffect(.degrees(orbitRotation))
            }
            .frame(height: 150)
            
            // Branding Title
            VStack(spacing: 4) {
                Text("FitBuddy")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(theme.appTheme == .light ? NeumorphicColors.lightTextHeadings : NeumorphicColors.darkTextHeadings)
                
                Text("Real-Time AI Computer Vision Fitness")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(theme.appTheme == .light ? NeumorphicColors.lightTextSecondary : NeumorphicColors.darkTextPrimary.opacity(0.7))
            }
        }
    }
    
    // MARK: - Motivational Quote Card
    private var motivationalQuoteCard: some View {
        let q = quotes[currentQuoteIndex]
        
        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: q.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.accentColor)
                
                Text(q.author.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(theme.accentColor)
                    .tracking(1.2)
                
                Spacer()
                
                // Quote Progress Dots
                HStack(spacing: 4) {
                    ForEach(0..<quotes.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentQuoteIndex ? theme.accentColor : theme.main.text.opacity(0.2))
                            .frame(width: i == currentQuoteIndex ? 14 : 5, height: 5)
                            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentQuoteIndex)
                    }
                }
            }
            
            Text("“\(q.quote)”")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(theme.main.text)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .opacity(quoteFade ? 1.0 : 0.0)
                .offset(y: quoteFade ? 0 : 6)
                .animation(.easeInOut(duration: 0.45), value: quoteFade)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .neumorphicCard(cornerRadius: 22)
    }
    
    // MARK: - Feature Ticker Row
    private var featureTickerRow: some View {
        HStack(spacing: 10) {
            featurePill(icon: "dot.viewfinder", value: "3D AI", label: "Vision", color: NeumorphicColors.dotRed)
            featurePill(icon: "bolt.fill", value: "100%", label: "Private", color: NeumorphicColors.dotYellow)
            featurePill(icon: "chart.line.uptrend.xyaxis", value: "Real-time", label: "Stats", color: NeumorphicColors.dotGreen)
        }
    }
    
    // MARK: - Action Section
    private var actionSection: some View {
        VStack(spacing: 14) {
            Button(action: {
                userController.signInWithGoogle()
            }) {
                HStack(spacing: 14) {
                    Image("google")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    
                    Text("Continue with Google")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(theme.appTheme == .light ? NeumorphicColors.lightTextHeadings : .white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .neumorphicCard(cornerRadius: 28, shadowRadius: 10, shadowDistance: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(theme.accentColor.opacity(0.35), lineWidth: 1.5)
                )
            }
            .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.95))
            
            Text("By continuing, you agree to our Terms & Privacy Policy")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.45))
            
            if let error = userController.authError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(NeumorphicColors.dotRed)
                    Text(error)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text)
                }
                .padding(12)
                .neumorphicCard(cornerRadius: 16, accentGlow: NeumorphicColors.dotRed.opacity(0.4))
                .multilineTextAlignment(.center)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    // MARK: - Feature Pill View
    @ViewBuilder
    private func featurePill(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color.opacity(0.18))
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color)
                }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.main.text)
                Text(label)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text.opacity(0.45))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .neumorphicCard(cornerRadius: 18)
    }
    
    // MARK: - Animation Controllers
    private func startContinuousAnimations() {
        // Subtle floating
        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
            floatOffset = -6
            isAnimating = true
        }
        
        // Pulse waves
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
            pulseScale = 1.07
            pulseOpacity = 0.2
        }
        
        // Orbital rotation
        withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
            orbitRotation = 360
        }
        
        // Ambient background orbs
        withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
            orb1Offset = CGSize(width: 80, height: -60)
            orb2Offset = CGSize(width: -70, height: 100)
        }
    }
    
    private func rotateQuote() {
        withAnimation(.easeOut(duration: 0.3)) {
            quoteFade = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
            withAnimation(.easeIn(duration: 0.35)) {
                quoteFade = true
            }
        }
    }
}

struct LoginPageView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPageView()
            .environmentObject(UserController())
            .environmentObject(AppThemeController())
    }
}

