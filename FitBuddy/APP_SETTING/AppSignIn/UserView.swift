//
//  UserView.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/9/25.
//

import SwiftUI
import Foundation


struct UserView: View {
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var theme: AppThemeController
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                if userController.profile == nil {
                    anonymousUser
                } else {
                    officialUser
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 100) // Padding for tab bar
        }
        .frame(width: UIScreen.main.bounds.width)
    }
    
    // MARK: - Official User State
    var officialUser: some View {
        VStack(spacing: 0) {
            // 1. Profile Header (Cover + Avatar)
            ZStack(alignment: .bottom) {
                // Cover Image / Gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 35, style: .continuous))
                .padding(.bottom, 50) // Space for avatar to overlap
                
                // Overlapping Avatar
                if let avatar = userController.profile?.avatarUrl, !avatar.isEmpty {
                    AsyncImage(url: URL(string: avatar)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(4)
                    .background(Circle().fill(.ultraThinMaterial))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(theme.main.text.opacity(0.5))
                        .padding(4)
                        .background(Circle().fill(.ultraThinMaterial))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
            }
            
            // 2. Name & Handle
            VStack(spacing: 4) {
                Text(userController.profile?.username ?? "No name")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.main.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text("@\(userController.profile?.userId ?? "")")
                    .font(.subheadline)
                    .foregroundColor(theme.main.text.opacity(0.7))
                    .lineLimit(1)
            }
            .padding(.top, 10)
            
            // 3. Stats Pills Row (Liquid Glass)
            HStack(spacing: 12) {
                statPill(icon: "flame.fill", value: "1,250", label: "Kcal")
                statPill(icon: "figure.run", value: "24", label: "Workouts")
                statPill(icon: "star.fill", value: "Lvl 5", label: "Pro")
            }
            .padding(.top, 24)
            .padding(.bottom, 24)
            .padding(.horizontal, 16)
            
            // 4. Action Button (Sign Out)
            Button(action: { userController.signOut() }) {
                HStack {
                    Spacer()
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .bold))
                    Text("Sign out")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                }
                .foregroundColor(theme.main.text)
                .padding(.vertical, 16)
                .minimalistBackground(cornerRadius: 25)
            }
            .buttonStyle(MinimalistStretchButtonStyle())
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        // Main Liquid Glass Card Wrap
        .background(
            Color.clear
                .minimalistBackground(cornerRadius: 35)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Anonymous User State
    var anonymousUser: some View {
        VStack(spacing: 30) {
            
            // Profile Graphic
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(theme.main.text.opacity(0.7))
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            }
            .padding(.top, 30)
            
            VStack(spacing: 8) {
                Text("Welcome to FitBuddy")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.main.text)
                
                Text("Sign in to save your workouts,\ntrack your calories, and connect with friends.")
                    .font(.subheadline)
                    .foregroundColor(theme.main.text.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Google Sign In Button
            Button(action: { userController.signInWithGoogle() }) {
                HStack(spacing: 12) {
                    Image("google")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(6)
                        .background(Circle().fill(.white))
                        .shadow(color: .black.opacity(0.1), radius: 2)
                    
                    Text("Continue with Google")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(theme.main.text)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .minimalistBackground(cornerRadius: 30)
            }
            .buttonStyle(MinimalistStretchButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        // Main Liquid Glass Card Wrap
        .background(
            Color.clear
                .minimalistBackground(cornerRadius: 35)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Reusable Components
    func statPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(theme.main.text)
                    .font(.system(size: 14))
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
            }
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.main.text.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        // Individual pill
        .minimalistBackground(cornerRadius: 20)
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground().ignoresSafeArea() // Assumes you have an AppBackground view for previewing
            UserView()
                .environmentObject(UserController())
                .environmentObject(AppThemeController())
        }
    }
}
