//
//  DeveloperView.swift
//  FitBuddy
//
//  Created by FitBuddy on 01/09/2026.
//

import SwiftUI
import SafariServices

struct DeveloperView: View {
    let onBack: () -> Void
    
    @EnvironmentObject var theme: AppThemeController
    @State private var activeSafariURL: IdentifiableURL? = nil
    
    var body: some View {
        ZStack {
            // Adaptive clean background
            (theme.appTheme == .light ? Color.white : theme.main.mainColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Navigation Header
                navigationBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // MARK: - Our Story Card
                        ourStoryCard
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                        
                        // MARK: - Developers Section
                        developersSection
                            .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 50)
                    }
                }
            }
        }
        .sheet(item: $activeSafariURL) { item in
            SafariSheet(url: item.url)
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
            
            Text("Developer")
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
    
    // MARK: - Our Story Card
    private var ourStoryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "sparkle")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.appTheme == .light ? .black : .white)
                
                Text("Our Story")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(theme.appTheme == .light ? .black : .white)
            }
            
            Text("FitBuddy was born from a shared dream: making personal training guidance and healthy living accessible to everyone through the power of on-device AI. In a world full of guesswork and expensive gym memberships, the genuine motivation of guided workouts often gets lost. FitBuddy changes that by providing an intelligent companion where computer vision and community bring us together, helping people form real, lasting healthy habits no matter where they are.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(theme.appTheme == .light ? Color.black.opacity(0.85) : Color.white.opacity(0.88))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(theme.appTheme == .light ? Color(red: 0.94, green: 0.94, blue: 0.96) : Color(red: 0.18, green: 0.20, blue: 0.24))
        )
    }
    
    // MARK: - Developers Section
    private var developersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Developers")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(theme.appTheme == .light ? .black : theme.main.text)
                .padding(.leading, 4)
            
            VStack(spacing: 14) {
                // Developer 1: Nguyen Huu Phuc Hung
                developerPill(
                    name: "Nguyen Huu Phuc Hung",
                    role: "Co-founder",
                    imageName: "PhucHung",
                    githubURL: "https://github.com/PhucHung2010"
                )
                
                // Developer 2: Nguyen An Phuoc
                developerPill(
                    name: "Nguyen An Phuoc",
                    role: "Co-founder",
                    imageName: "AnPhuoc",
                    githubURL: "https://github.com/ap-bipo"
                )
            }
        }
    }
    
    // MARK: - Developer Pill Row
    private func developerPill(name: String, role: String, imageName: String, githubURL: String) -> some View {
        Button(action: {
            if let url = URL(string: githubURL) {
                activeSafariURL = IdentifiableURL(url: url)
            }
        }) {
            HStack(spacing: 16) {
                // Avatar
                avatarView(name: imageName)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                    )
                
                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(role)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.65))
                }
                
                Spacer()
                
                // Subtle GitHub indicator
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(
                Capsule()
                    .fill(Color.black)
                    .shadow(color: Color.black.opacity(0.18), radius: 8, y: 4)
            )
        }
        .buttonStyle(DeveloperPillButtonStyle())
    }
    
    // MARK: - Avatar View Loader
    @ViewBuilder
    private func avatarView(name: String) -> some View {
        if let uiImage = UIImage(named: name) ?? loadFromBundle(name) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private func loadFromBundle(_ name: String) -> UIImage? {
        if let path = Bundle.main.path(forResource: name, ofType: "jpg", inDirectory: "CREATOR") ?? Bundle.main.path(forResource: name, ofType: "jpg") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
}

// MARK: - Button Style
struct DeveloperPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

// MARK: - Safari Representable & Wrapper
struct SafariSheet: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        return SFSafariViewController(url: url, configuration: config)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct DeveloperView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperView(onBack: {})
            .environmentObject(AppThemeController())
    }
}
