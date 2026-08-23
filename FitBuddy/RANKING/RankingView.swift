//
//  RankingView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 03/06/2025.
//

import SwiftUI

struct RankingView: View {
    @EnvironmentObject var theme: AppThemeController
    @State private var selectedPeriod = 0
    let periods = ["Today", "Weekly", "All Time"]
    
    struct LeaderboardUser: Identifiable {
        let id = UUID()
        let rank: Int
        let name: String
        let handle: String
        let score: Int
        let isCurrentUser: Bool
    }
    
    let topUsers: [LeaderboardUser] = [
        LeaderboardUser(rank: 1, name: "Alex Chen", handle: "alexc", score: 4820, isCurrentUser: false),
        LeaderboardUser(rank: 2, name: "Sarah Connor", handle: "sarah_fit", score: 4210, isCurrentUser: false),
        LeaderboardUser(rank: 3, name: "Marcus Vance", handle: "marcusv", score: 3950, isCurrentUser: false),
        LeaderboardUser(rank: 4, name: "You", handle: "fitbuddy", score: 3420, isCurrentUser: true),
        LeaderboardUser(rank: 5, name: "Elena Rostova", handle: "elena_r", score: 3180, isCurrentUser: false),
        LeaderboardUser(rank: 6, name: "David Kim", handle: "dkim_workout", score: 2990, isCurrentUser: false),
        LeaderboardUser(rank: 7, name: "Maya Patel", handle: "mayapt", score: 2840, isCurrentUser: false),
    ]
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Leaderboard")
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(theme.main.text)
                            Text("Top athletes this week")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        NeumorphicIndicatorDots(dotSize: 5, spacing: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Timeframe Switcher
                    HStack(spacing: 6) {
                        ForEach(0..<periods.count, id: \.self) { index in
                            let isSelected = selectedPeriod == index
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    selectedPeriod = index
                                }
                            }) {
                                Text(periods[index])
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(isSelected ? .white : theme.main.text.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background {
                                        if isSelected {
                                            Capsule()
                                                .fill(theme.accentGradient)
                                                .shadow(color: theme.accentColor.opacity(0.3), radius: 4, y: 2)
                                        }
                                    }
                            }
                            .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.94))
                        }
                    }
                    .padding(4)
                    .neumorphicInset(cornerRadius: 22)
                    .padding(.horizontal, 20)
                    
                    // Top 3 Podium
                    HStack(alignment: .bottom, spacing: 14) {
                        podiumItem(user: topUsers[1], height: 120, medalColor: Color(red: 0.75, green: 0.75, blue: 0.78), medalIcon: "2")
                        podiumItem(user: topUsers[0], height: 145, medalColor: Color(red: 1.0, green: 0.84, blue: 0.0), medalIcon: "1")
                        podiumItem(user: topUsers[2], height: 105, medalColor: Color(red: 0.80, green: 0.50, blue: 0.20), medalIcon: "3")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Ranked List
                    VStack(spacing: 10) {
                        ForEach(topUsers.dropFirst(3)) { user in
                            HStack(spacing: 14) {
                                Text("#\(user.rank)")
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                    .foregroundColor(theme.main.text.opacity(0.4))
                                    .frame(width: 30)
                                
                                Circle()
                                    .fill(user.isCurrentUser ? theme.accentGradient : NeumorphicColors.blueGradient)
                                    .frame(width: 42, height: 42)
                                    .overlay {
                                        Text(String(user.name.prefix(1)))
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    .neumorphicCircle()
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.name)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(theme.main.text)
                                    Text("@\(user.handle)")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(theme.accentColor)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(theme.accentColor)
                                    Text("\(user.score)")
                                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                                        .foregroundColor(theme.main.text)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .neumorphicInset(cornerRadius: 12)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .neumorphicCard(cornerRadius: 20, accentGlow: user.isCurrentUser ? theme.accentColor.opacity(0.4) : nil)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 100)
                }
            }
        }
    }
    
    @ViewBuilder
    func podiumItem(user: LeaderboardUser, height: CGFloat, medalColor: Color, medalIcon: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(theme.accentGradient)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .neumorphicCircle()
                
                Circle()
                    .fill(medalColor)
                    .frame(width: 22, height: 22)
                    .overlay {
                        Text(medalIcon)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .offset(x: 18, y: 18)
                    .shadow(color: Color.black.opacity(0.2), radius: 3, y: 1)
            }
            
            Text(user.name)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(theme.main.text)
                .lineLimit(1)
            
            HStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.25))
                Text("\(user.score)")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.main.text)
            }
            
            VStack {
                Spacer()
                Text("#\(user.rank)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(theme.main.text.opacity(0.35))
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .neumorphicCard(cornerRadius: 18)
        }
        .frame(maxWidth: .infinity)
    }
}
