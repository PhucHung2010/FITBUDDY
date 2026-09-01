//
//  ContestDetailView.swift
//  FitBuddy
//
//  Created by FitBuddy on 25/08/2025.
//

import SwiftUI

struct ContestDetailView: View {
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var tabViewController: TabViewController
    @Environment(\.dismiss) var dismiss
    
    let contest: Contest
    
    @State private var leaderboard: [ContestLeaderboardEntry] = []
    @State private var isLoadingLeaderboard = false
    @State private var showTraining = false
    @State private var contestCompleted = false
    
    var category: Category? {
        FitnessExerciseCategory().loadCategory(named: contest.exerciseName)
    }
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            if showTraining {
                ContestTrainingView(
                    contest: contest,
                    category: category,
                    onComplete: { success in
                        showTraining = false
                        tabViewController.showTabBar = true
                        if success {
                            contestCompleted = true
                            Task {
                                await loadLeaderboard(force: true)
                            }
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Navigation Bar
                        navBar
                        
                        // Hero Section
                        heroSection
                        
                        // Challenge Info
                        challengeInfo
                        
                        // Action Button
                        actionButton
                        
                        // Leaderboard Section
                        leaderboardSection
                        
                        Spacer().frame(height: 40)
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 1), value: showTraining)
        .task {
            await loadLeaderboard()
        }
    }
    
    // MARK: - Navigation Bar
    var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(theme.main.text)
                    .frame(width: 44, height: 44)
                    .neumorphicCircle()
            }
            .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.9))
            
            Spacer()
            
            Text("Challenge")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(theme.main.text)
            
            Spacer()
            
            NeumorphicIndicatorDots(dotSize: 5, spacing: 4)
                .frame(width: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    // MARK: - Hero Section
    var heroSection: some View {
        VStack(spacing: 14) {
            // Exercise Image
            if let cat = category, let firstImage = cat.images.first {
                HStack(spacing: 6) {
                    Image(firstImage.0)
                        .resizable()
                        .scaledToFit()
                    Image(firstImage.1)
                        .resizable()
                        .scaledToFit()
                }
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 10)
            }
            
            // Title
            Text(contest.title)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(theme.main.text)
                .multilineTextAlignment(.center)
            
            // Exercise Name Badge
            Text(contest.exerciseName)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Capsule().fill(theme.accentGradient))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .neumorphicCard(cornerRadius: 28)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Challenge Info
    var challengeInfo: some View {
        VStack(spacing: 14) {
            // Description
            Text(contest.description)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.7))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider().opacity(0.3)
            
            // Info Grid
            HStack(spacing: 0) {
                InfoTile(icon: contest.difficultyLevel.iconName,
                         value: contest.difficultyLevel.displayName,
                         label: "Difficulty",
                         color: difficultyColor)
                
                InfoTile(icon: "star.fill",
                         value: "\(contest.safePointsReward)",
                         label: "Max Points",
                         color: Color(red: 1.0, green: 0.72, blue: 0.12))
                
                if let reps = contest.targetReps {
                    InfoTile(icon: "repeat",
                             value: "\(reps)",
                             label: "Target Reps",
                             color: theme.accentColor)
                }
                
                InfoTile(icon: "person.2.fill",
                         value: "\(contest.safeParticipantCount)",
                         label: "Joined",
                         color: NeumorphicColors.dotBlue)
            }
            
            // Attempts Progress Tracker
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.badge.clock.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(theme.accentColor)
                        Text("Attempts")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text)
                    }
                    
                    Spacer()
                    
                    Text("\(contest.attemptsUsed)/\(contest.maxAttempts) Tries Used")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(contest.remainingTries > 0 ? theme.accentColor : theme.main.text.opacity(0.4))
                }
                
                HStack(spacing: 8) {
                    ForEach(1...contest.maxAttempts, id: \.self) { attempt in
                        HStack(spacing: 4) {
                            if attempt <= contest.attemptsUsed {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(NeumorphicColors.dotGreen)
                                Text("Try \(attempt)")
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .foregroundColor(NeumorphicColors.dotGreen)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(theme.main.text.opacity(0.35))
                                Text("Try \(attempt)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.main.text.opacity(0.45))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(attempt <= contest.attemptsUsed ? NeumorphicColors.dotGreen.opacity(0.12) : theme.main.text.opacity(0.04))
                        )
                    }
                }
            }
            .padding(.top, 4)
            
            // Deadline
            if let timeLeft = contest.timeRemainingText {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(NeumorphicColors.dotRed)
                    Text(timeLeft)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .neumorphicInset(cornerRadius: 14)
            }
        }
        .padding(18)
        .neumorphicCard(cornerRadius: 24)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Action Button
    var actionButton: some View {
        Group {
            if contest.remainingTries == 0 && contest.isSubmitted {
                // Completed all 3 attempts
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text("Completed (3/3 Tries) — Best: \(contest.userPoints ?? 0) pts")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(NeumorphicColors.greenGradient)
                )
                .shadow(color: NeumorphicColors.dotGreen.opacity(0.3), radius: 8, y: 4)
                .padding(.horizontal, 20)
            } else if category != nil && contest.canAttempt {
                // Start or Retry Challenge button
                Button(action: {
                    tabViewController.showTabBar = false
                    withAnimation {
                        showTraining = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: contest.attemptsUsed > 0 ? "arrow.clockwise" : "bolt.fill")
                            .font(.system(size: 18, weight: .bold))
                        if contest.attemptsUsed == 0 {
                            Text("Start Challenge (3 Tries Available)")
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                        } else {
                            Text("Try Again (\(contest.remainingTries) \(contest.remainingTries == 1 ? "try" : "tries") left) • Best: \(contest.userPoints ?? 0) pts")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(theme.accentGradient)
                    )
                    .shadow(color: theme.accentColor.opacity(0.35), radius: 8, y: 4)
                }
                .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
                .padding(.horizontal, 20)
            } else {
                // Exercise not found or expired
                Text(contest.isExpired ? "Challenge Expired" : "Exercise not available")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(theme.main.text.opacity(0.4))
                    .padding()
            }
        }
    }
    
    // MARK: - Leaderboard Section
    var leaderboardSection: some View {
        VStack(spacing: 12) {
            HStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(theme.accentGradient)
                    .frame(width: 4, height: 18)
                Text("Leaderboard")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
                Spacer()
                NeumorphicIndicatorDots(dotSize: 4, spacing: 3)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .neumorphicCard(cornerRadius: 18)
            
            if isLoadingLeaderboard {
                ProgressView()
                    .padding(.vertical, 20)
            } else if leaderboard.isEmpty {
                Text("No submissions yet — be the first!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(theme.main.text.opacity(0.4))
                    .padding(.vertical, 20)
            } else {
                ForEach(leaderboard) { entry in
                    let isCurrentUser = entry.userId == userController.profile?.id
                    
                    HStack(spacing: 12) {
                        // Rank
                        Text("#\(entry.rank)")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(entry.rank <= 3 ? .white : theme.main.text.opacity(0.4))
                            .frame(width: 32, height: 32)
                            .background {
                                if entry.rank <= 3 {
                                    Circle().fill(rankGradient(for: entry.rank))
                                }
                            }
                        
                        // Avatar
                        Circle()
                            .fill(isCurrentUser ? theme.accentGradient : NeumorphicColors.blueGradient)
                            .frame(width: 38, height: 38)
                            .overlay {
                                Text(String(entry.username.prefix(1)).uppercased())
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        
                        // Name + Accuracy
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.username)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(theme.main.text)
                            Text("\(entry.accuracy)% accuracy")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(theme.accentColor.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Points
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.accentColor)
                            Text("\(entry.pointsEarned)")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundColor(theme.main.text)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .neumorphicInset(cornerRadius: 12)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .neumorphicCard(cornerRadius: 18, accentGlow: isCurrentUser ? theme.accentColor.opacity(0.4) : nil)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helpers
    var difficultyColor: Color {
        switch contest.difficultyLevel {
        case .easy: return NeumorphicColors.dotGreen
        case .medium: return Color(red: 1.0, green: 0.72, blue: 0.12)
        case .hard: return NeumorphicColors.dotRed
        }
    }
    
    func rankGradient(for rank: Int) -> LinearGradient {
        switch rank {
        case 1: return LinearGradient(colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.68, blue: 0.0)], startPoint: .top, endPoint: .bottom)
        case 2: return LinearGradient(colors: [Color(red: 0.75, green: 0.75, blue: 0.78), Color(red: 0.60, green: 0.62, blue: 0.66)], startPoint: .top, endPoint: .bottom)
        case 3: return LinearGradient(colors: [Color(red: 0.80, green: 0.50, blue: 0.20), Color(red: 0.65, green: 0.38, blue: 0.15)], startPoint: .top, endPoint: .bottom)
        default: return theme.accentGradient
        }
    }
    
    func loadLeaderboard(force: Bool = false) async {
        isLoadingLeaderboard = true
        leaderboard = await ContestService.shared.fetchLeaderboard(contestId: contest.id, forceRefresh: force)
        isLoadingLeaderboard = false
    }
}

// MARK: - Info Tile
struct InfoTile: View {
    @EnvironmentObject var theme: AppThemeController
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(theme.main.text)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
    }
}
