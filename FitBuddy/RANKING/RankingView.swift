//
//  RankingView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 03/06/2025.
//

import SwiftUI

struct RankingView: View {
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var userController: UserController
    var onBack: (() -> Void)? = nil
    
    @State private var liveRankings: [GlobalRankingEntry] = []
    @State private var isLoading = false
    
    struct LeaderboardUser: Identifiable {
        let id: UUID
        let rank: Int
        let name: String
        let handle: String
        let score: Int
        let isCurrentUser: Bool
    }
    
    var topUsers: [LeaderboardUser] {
        liveRankings.map { entry in
            LeaderboardUser(
                id: entry.userId,
                rank: entry.rank,
                name: entry.username,
                handle: entry.username.lowercased().replacingOccurrences(of: " ", with: "_"),
                score: entry.totalPoints,
                isCurrentUser: entry.userId == userController.profile?.id
            )
        }
    }
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Bar
                    HStack(spacing: 12) {
                        if let onBack = onBack {
                            Button(action: onBack) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(theme.main.text)
                                    .frame(width: 42, height: 42)
                                    .neumorphicCircle()
                            }
                            .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.9))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Leaderboard")
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(theme.main.text)
                            Text("Top athletes & contest winners")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        NeumorphicIndicatorDots(dotSize: 5, spacing: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    if isLoading && topUsers.isEmpty {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading athletes...")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else if topUsers.isEmpty {
                        // Empty State
                        VStack(spacing: 14) {
                            Image(systemName: "trophy")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(theme.main.text.opacity(0.25))
                            Text("No Athlete Rankings Yet")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.6))
                            Text("Complete a contest challenge to claim the #1 spot on the leaderboard!")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            if let onBack = onBack {
                                Button(action: onBack) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 13, weight: .bold))
                                        Text("Join a Challenge")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(theme.accentGradient))
                                }
                                .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.94))
                                .padding(.top, 6)
                            }
                        }
                        .padding(.vertical, 36)
                        .frame(maxWidth: .infinity)
                        .neumorphicCard(cornerRadius: 24)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    } else {
                        // Top 3 Podium (if >= 3 users)
                        if topUsers.count >= 3 {
                            HStack(alignment: .bottom, spacing: 14) {
                                podiumItem(user: topUsers[1], height: 120, medalColor: Color(red: 0.75, green: 0.75, blue: 0.78), medalIcon: "2")
                                podiumItem(user: topUsers[0], height: 145, medalColor: Color(red: 1.0, green: 0.84, blue: 0.0), medalIcon: "1")
                                podiumItem(user: topUsers[2], height: 105, medalColor: Color(red: 0.80, green: 0.50, blue: 0.20), medalIcon: "3")
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            
                            // Ranked List (from 4th onwards)
                            VStack(spacing: 10) {
                                ForEach(topUsers.dropFirst(3)) { user in
                                    rankedUserRow(user: user)
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            // If fewer than 3 users, show all in a ranked list
                            VStack(spacing: 10) {
                                ForEach(topUsers) { user in
                                    rankedUserRow(user: user)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }
                    }
                    
                    Spacer().frame(height: 100)
                }
            }
            .refreshable {
                await loadRanking(force: true)
            }
        }
        .task {
            await loadRanking()
        }
    }
    
    func loadRanking(force: Bool = false) async {
        isLoading = true
        let results = await ContestService.shared.fetchGlobalRanking(forceRefresh: force)
        await MainActor.run {
            self.liveRankings = results
            self.isLoading = false
        }
    }
    
    @ViewBuilder
    func rankedUserRow(user: LeaderboardUser) -> some View {
        HStack(spacing: 14) {
            Text("#\(user.rank)")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.4))
                .frame(width: 30)
            
            Circle()
                .fill(user.isCurrentUser ? theme.accentGradient : NeumorphicColors.blueGradient)
                .frame(width: 42, height: 42)
                .overlay {
                    Text(String(user.name.prefix(1)).uppercased())
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
    
    @ViewBuilder
    func podiumItem(user: LeaderboardUser, height: CGFloat, medalColor: Color, medalIcon: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(theme.accentGradient)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Text(String(user.name.prefix(1)).uppercased())
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
