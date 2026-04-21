//
//  ContestDetailView.swift
//  FitBuddy
//
//  Contest detail: task info, leaderboard, start exercise.
//

import SwiftUI
import Foundation

struct ContestDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: SupabaseAuthManager
    @EnvironmentObject var theme: AppThemeController
    
    let contest: ContestModel
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Task Info Card
                    taskInfoCard
                    
                    // Contest Stats
                    statsRow
                    
                    // Leaderboard
                    leaderboardSection
                }
                .padding(.bottom, 40)
            }
        }
        .task {
            await authManager.fetchLeaderboard(contestId: contest.id)
        }
    }
    
    // MARK: - Header
    var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(theme.main.text.opacity(0.7))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Contest icon
            ZStack {
                Circle()
                    .fill(Color(hex: contest.colorHex ?? contest.difficultyColor).opacity(0.2))
                    .frame(width: 80, height: 80)
                Image(systemName: contest.iconSystemName ?? "trophy.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: contest.colorHex ?? contest.difficultyColor))
            }
            
            Text(contest.title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(theme.main.text)
                .multilineTextAlignment(.center)
            
            Text(contest.difficultyPoints)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: contest.difficultyColor))
            
            if let desc = contest.description {
                Text(desc)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(theme.main.text.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - Task Info Card
    var taskInfoCard: some View {
        VStack(spacing: 14) {
            Text("Task")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(theme.main.text.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                // Exercise info
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .foregroundColor(Color(hex: contest.colorHex ?? "#4CAF50"))
                        Text(contest.exerciseName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text)
                    }
                    
                    Text("Complete \(contest.targetReps) reps with the best accuracy")
                        .font(.system(size: 13))
                        .foregroundColor(theme.main.text.opacity(0.6))
                }
                
                Spacer()
                
                // Rep target badge
                VStack(spacing: 2) {
                    Text("\(contest.targetReps)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: contest.colorHex ?? "#4CAF50"))
                    Text("reps")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.main.text.opacity(0.5))
                }
            }
        }
        .padding(16)
        .background { BlurView(style: theme.main.ultraThinMaterial) }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
    }
    
    // MARK: - Stats Row
    var statsRow: some View {
        HStack(spacing: 12) {
            StatBox(icon: "person.2.fill", value: "\(contest.participantCount)", label: "Joined", theme: theme)
            StatBox(icon: "star.fill", value: "+\(contest.pointsReward)", label: "Points", theme: theme)
            StatBox(icon: "flame.fill", value: contest.difficulty.capitalized, label: "Level", theme: theme)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Leaderboard
    var leaderboardSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("🏆 Leaderboard")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
                Spacer()
                
                Button(action: { Task { await authManager.fetchLeaderboard(contestId: contest.id) } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.main.text.opacity(0.5))
                }
            }
            .padding(.horizontal, 20)
            
            if authManager.leaderboard.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 36))
                        .foregroundColor(theme.main.text.opacity(0.3))
                    Text("No completions yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.main.text.opacity(0.4))
                    Text("Be the first to complete this contest!")
                        .font(.system(size: 12))
                        .foregroundColor(theme.main.text.opacity(0.3))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(Array(authManager.leaderboard.enumerated()), id: \.element.id) { index, entry in
                    LeaderboardRow(
                        rank: index + 1,
                        entry: entry,
                        isCurrentUser: entry.userId == authManager.currentUser?.id.uuidString,
                        theme: theme
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let theme: AppThemeController
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(theme.main.text.opacity(0.6))
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(theme.main.text)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(theme.main.text.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background { BlurView(style: theme.main.ultraThinMaterial) }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    let theme: AppThemeController
    
    private var rankIcon: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text(rankIcon)
                .font(.system(size: rank <= 3 ? 22 : 16, weight: .bold, design: .rounded))
                .foregroundColor(theme.main.text)
                .frame(width: 36)
            
            // Avatar
            if let avatarUrl = entry.profiles?.avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Circle().fill(theme.main.text.opacity(0.1))
                    }
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(theme.main.text.opacity(0.4))
                    .frame(width: 36, height: 36)
            }
            
            // Name
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.profiles?.name ?? "User")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isCurrentUser ? .blue : theme.main.text)
                    .lineLimit(1)
                
                if let username = entry.profiles?.username, !username.isEmpty {
                    Text("@\(username)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.main.text.opacity(0.4))
                }
            }
            
            Spacer()
            
            // Accuracy + Time
            VStack(alignment: .trailing, spacing: 2) {
                if let acc = entry.accuracy {
                    Text(String(format: "%.1f%%", acc))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(acc >= 90 ? .green : (acc >= 70 ? .yellow : .orange))
                }
                if let time = entry.timeSeconds {
                    Text(String(format: "%.1fs", time))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.main.text.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            if isCurrentUser {
                BlurView(style: theme.main.normalMaterial)
            } else {
                BlurView(style: theme.main.ultraThinMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            if rank == 1 {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.4), lineWidth: 1.5)
            }
        }
    }
}
