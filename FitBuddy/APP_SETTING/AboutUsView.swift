//
//  AboutUsView.swift
//  FitBuddy
//
//  Created by FitBuddy on 01/09/2026.
//

import SwiftUI
import SafariServices

struct AboutUsView: View {
    let onBack: () -> Void
    
    @EnvironmentObject var theme: AppThemeController
    @State private var showDeveloper: Bool = false
    @State private var activeSafariURL: IdentifiableURL? = nil
    
    private let websiteURL = "https://ap-bipo.github.io/FITBUDDY_HELP_CENTER"
    private let privacyURL = "https://ap-bipo.github.io/FITBUDDY_HELP_CENTER/privacy.html"
    private let reportURL = "https://ap-bipo.github.io/FITBUDDY_HELP_CENTER/report-bug.html"
    
    var body: some View {
        ZStack {
            if showDeveloper {
                DeveloperView(onBack: {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.85)) {
                        showDeveloper = false
                    }
                })
                .transition(.move(edge: .trailing))
            } else {
                aboutUsMainContent
                    .transition(.move(edge: .leading))
            }
        }
        .sheet(item: $activeSafariURL) { item in
            SafariSheet(url: item.url)
        }
    }
    
    // MARK: - Main About Us Content
    private var aboutUsMainContent: some View {
        ZStack {
            (theme.appTheme == .light ? Color.white : theme.main.mainColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                navigationBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 36)
                        
                        // App Logo Card
                        appLogoCard
                        
                        Spacer().frame(height: 20)
                        
                        // App Name Title
                        Text("FitBuddy")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(theme.appTheme == .light ? .black : theme.main.text)
                        
                        Spacer().frame(height: 48)
                        
                        // Action Pill Buttons
                        VStack(spacing: 14) {
                            // 1. Website
                            actionPillButton(
                                title: "Website",
                                systemImage: "globe"
                            ) {
                                openWeb(websiteURL)
                            }
                            
                            // 2. Privacy Policy
                            actionPillButton(
                                title: "Privacy Policy",
                                systemImage: "shield.fill"
                            ) {
                                openWeb(privacyURL)
                            }
                            
                            // 3. Developer
                            actionPillButton(
                                title: "Developer",
                                systemImage: "person.2.fill"
                            ) {
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.85)) {
                                    showDeveloper = true
                                }
                            }
                            
                            // 4. App Report
                            actionPillButton(
                                title: "App Report",
                                systemImage: "doc.text.fill"
                            ) {
                                openWeb(reportURL)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 60)
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.85)) {
                    onBack()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.appTheme == .light ? .black : theme.main.text)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            
            Spacer()
            
            Text("About Us")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.appTheme == .light ? .black : theme.main.text)
            
            Spacer()
            
            // Symmetrical balance
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
    
    // MARK: - App Logo Card
    private var appLogoCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.white)
                .frame(width: 148, height: 148)
                .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 8)
            
            logoImageView
                .frame(width: 104, height: 104)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
    
    @ViewBuilder
    private var logoImageView: some View {
        if let img = UIImage(named: "AppLogo") ?? UIImage(named: "att.At2KM332E2AiNcs9c9eNaCXBU0d8LCvrGvZNQL46PXA") ?? loadLogoFromBundle() {
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
        } else {
            // High-fidelity fallback vector dumbbell
            Image(systemName: "dumbbell.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.black)
                .padding(16)
        }
    }
    
    private func loadLogoFromBundle() -> UIImage? {
        if let path = Bundle.main.path(forResource: "att.At2KM332E2AiNcs9c9eNaCXBU0d8LCvrGvZNQL46PXA", ofType: "jpeg") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
    
    // MARK: - Action Pill Button
    private func actionPillButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .bold))
                
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Capsule()
                    .fill(Color.black)
                    .shadow(color: Color.black.opacity(0.14), radius: 8, y: 4)
            )
        }
        .buttonStyle(ActionPillButtonStyle())
    }
    
    // MARK: - Open Web Helper
    private func openWeb(_ urlString: String) {
        if let url = URL(string: urlString) {
            activeSafariURL = IdentifiableURL(url: url)
        }
    }
}

// MARK: - Button Style
struct ActionPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView(onBack: {})
            .environmentObject(AppThemeController())
    }
}
