//
//  ContestView.swift
//  FitBuddy
//
//  Created by FitBuddy on 25/08/2025.
//

import SwiftUI

struct ContestView: View {
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var tabViewController: TabViewController
    @StateObject private var contestService = ContestService.shared
    
    @State private var selectedContest: Contest?
    @State private var showDetail = false
    @State private var selectedSection = 0
    let sections = ["Challenges", "Leaderboard"]
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            if selectedSection == 1 {
                RankingView(onBack: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedSection = 0
                    }
                })
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        headerView
                        
                        // Section Switcher
                        sectionSwitcher
                        
                        // Stats Banner
                        statsBanner
                        
                        // Contest List
                        if contestService.isLoading && contestService.contests.isEmpty {
                            loadingView
                        } else if contestService.contests.isEmpty {
                            emptyView
                        } else {
                            contestList
                        }
                        
                        Spacer().frame(height: 100)
                    }
                }
                .refreshable {
                    await refreshContests()
                }
            }
        }
        .task {
            await refreshContests()
        }
        .fullScreenCover(item: $selectedContest) { contest in
            ContestDetailView(contest: contest)
                .environmentObject(theme)
                .environmentObject(userController)
                .environmentObject(tabViewController)
        }
    }
    
    // MARK: - Header
    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Contests")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.main.text)
                Text("Complete challenges, earn points")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(theme.main.text.opacity(0.5))
            }
            
            Spacer()
            
            NeumorphicIndicatorDots(dotSize: 5, spacing: 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Section Switcher
    var sectionSwitcher: some View {
        HStack(spacing: 6) {
            ForEach(0..<sections.count, id: \.self) { index in
                let isSelected = selectedSection == index
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedSection = index
                    }
                }) {
                    Text(sections[index])
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
    }
    
    // MARK: - Stats Banner
    var statsBanner: some View {
        let completedCount = contestService.contests.filter { $0.isSubmitted }.count
        let totalPoints = contestService.contests.compactMap { $0.userPoints }.reduce(0, +)
        
        return HStack(spacing: 14) {
            StatPill(icon: "trophy.fill", value: "\(completedCount)", label: "Completed", gradient: NeumorphicColors.greenGradient)
            StatPill(icon: "flame.fill", value: "\(totalPoints)", label: "Points", gradient: NeumorphicColors.orangeGradient)
            StatPill(icon: "flag.fill", value: "\(contestService.contests.count)", label: "Active", gradient: NeumorphicColors.blueGradient)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Contest List
    var contestList: some View {
        LazyVStack(spacing: 14) {
            ForEach(contestService.contests) { contest in
                Button(action: {
                    selectedContest = contest
                }) {
                    ContestCard(contest: contest)
                }
                .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Loading View
    var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading contests...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    // MARK: - Empty View
    var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(theme.main.text.opacity(0.25))
            Text("No active contests")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.5))
            Text("Check back later for new challenges!")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .neumorphicCard(cornerRadius: 24)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Refresh
    func refreshContests() async {
        await contestService.fetchActiveContests(userId: userController.profile?.id, forceRefresh: true)
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    @EnvironmentObject var theme: AppThemeController
    let icon: String
    let value: String
    let label: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                Text(value)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(gradient))
            
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .neumorphicCard(cornerRadius: 18)
    }
}

// MARK: - Contest Card
struct ContestCard: View {
    @EnvironmentObject var theme: AppThemeController
    let contest: Contest
    
    var difficultyColor: LinearGradient {
        switch contest.difficultyLevel {
        case .easy: return NeumorphicColors.greenGradient
        case .medium: return LinearGradient(
            colors: [Color(red: 1.0, green: 0.72, blue: 0.12), Color(red: 1.0, green: 0.54, blue: 0.18)],
            startPoint: .leading, endPoint: .trailing)
        case .hard: return NeumorphicColors.coralGradient
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row: Exercise name + Difficulty badge
            HStack {
                // Exercise image thumbnail
                if let category = FitnessExerciseCategory().loadCategory(named: contest.exerciseName),
                   let firstImage = category.images.first {
                    HStack(spacing: 2) {
                        Image(firstImage.0)
                            .resizable()
                            .scaledToFit()
                        Image(firstImage.1)
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 64, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(contest.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text)
                        .lineLimit(1)
                    
                    Text(contest.exerciseName)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(theme.accentColor)
                }
                
                Spacer()
                
                // Difficulty Badge
                HStack(spacing: 3) {
                    Image(systemName: contest.difficultyLevel.iconName)
                        .font(.system(size: 10, weight: .bold))
                    Text(contest.difficultyLevel.displayName)
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(difficultyColor))
            }
            
            // Description
            Text(contest.description)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.6))
                .lineLimit(2)
            
            // Bottom Row: Stats
            HStack(spacing: 16) {
                // Points reward
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.12))
                    Text("\(contest.safePointsReward) pts")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text.opacity(0.7))
                }
                
                // Participants
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(theme.accentColor.opacity(0.7))
                    Text("\(contest.safeParticipantCount)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text.opacity(0.7))
                }
                
                // Deadline
                if let timeLeft = contest.timeRemainingText {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(NeumorphicColors.dotRed)
                        Text(timeLeft)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Completed / Remaining Tries Badge OR target info
                if contest.remainingTries == 0 && contest.isSubmitted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text("\(contest.userPoints ?? 0) pts (3/3)")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(NeumorphicColors.greenGradient))
                } else if contest.attemptsUsed > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .bold))
                        Text("\(contest.remainingTries) left • \(contest.userPoints ?? 0) pts")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(theme.accentGradient))
                } else if let reps = contest.targetReps {
                    HStack(spacing: 3) {
                        Text("\(reps) reps")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.6))
                        Text("• 3 tries")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.accentColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .neumorphicInset(cornerRadius: 10)
                }
            }
        }
        .padding(16)
        .neumorphicCard(cornerRadius: 22, accentGlow: contest.remainingTries == 0 ? NeumorphicColors.dotGreen.opacity(0.3) : nil)
    }
}
