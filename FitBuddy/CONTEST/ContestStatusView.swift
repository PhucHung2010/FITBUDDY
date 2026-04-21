//
//  ContestStatusView.swift
//  FitBuddy
//
//  Codeforces-style contest status page.
//  Reusable for any contest — shows problem, user status, and live standings.
//  Exercise training is self-contained — no link to the exercise library settings.
//

import SwiftUI
import Foundation

struct ContestStatusView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: SupabaseAuthManager
    @EnvironmentObject var theme: AppThemeController
    @Environment(\.managedObjectContext) var viewContext
    
    let contest: ContestModel
    
    @State private var myResult: ContestParticipant? = nil
    @State private var isLoading = true
    
    // Contest Training (self-contained, no link to exercise library)
    @StateObject private var exercisePerformance = FitnessExercisePerformance()
    @State private var contestCategory: Category? = nil
    @State private var trainingPhase: ContestTrainingPhase = .idle
    @State private var hasSubmittedThisSession = false
    
    private var accentColor: Color {
        Color(hex: contest.colorHex ?? contest.difficultyColor)
    }
    
    // Find the matching Category from exercise library (read-only, for pose detection config)
    private var matchedCategory: Category? {
        FitnessExerciseCategory().loadCategory(named: contest.exerciseName)
    }
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            switch trainingPhase {
            case .idle:
                // Contest status page
                contestStatusContent
                
            case .training:
                // Direct to pose detection — no settings page
                PoseDetectionView(exercisePerformance: exercisePerformance)
                    .transition(.move(edge: .trailing))
                
            case .summary:
                // Show summary with contest results
                ContestSummaryView(
                    contest: contest,
                    exercisePerformance: exercisePerformance,
                    onDone: {
                        exercisePerformance.reinitialize()
                        trainingPhase = .idle
                        hasSubmittedThisSession = false
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 1), value: trainingPhase)
        .task {
            await loadContestData()
        }
        // Monitor when user taps "Finish" in StatusBar → exerciseStatus goes to .summary
        .onChange(of: exercisePerformance.exerciseStatus) { newStatus in
            if newStatus == .summary && trainingPhase == .training {
                submitAndShowSummary()
            }
        }
        // Auto-finish when target reps reached
        .onChange(of: exercisePerformance.totalCorrect) { newCount in
            if trainingPhase == .training,
               let target = exercisePerformance.targetCount,
               newCount >= target {
                // Stop the camera/pose detection
                exercisePerformance.quickPose.stop()
                // Move to summary
                exercisePerformance.exerciseStatus = .summary
                submitAndShowSummary()
            }
        }
    }
    
    /// Submit results to Supabase and transition to summary
    private func submitAndShowSummary() {
        guard !hasSubmittedThisSession else { return }
        hasSubmittedThisSession = true
        
        let totalReps = exercisePerformance.totalCorrect + exercisePerformance.totalIncorrect
        let accuracy = totalReps > 0
            ? (Double(exercisePerformance.totalCorrect) / Double(totalReps)) * 100.0
            : 0.0
        let time = Double(exercisePerformance.totalTime)
        
        let contestIdLocal = contest.id
        let pointsLocal = contest.pointsReward
        
        Task.detached { @MainActor in
            await authManager.submitContestResult(
                contestId: contestIdLocal,
                accuracy: accuracy,
                timeSeconds: time
            )
            await authManager.awardContestPoints(
                contestId: contestIdLocal,
                pointsReward: pointsLocal
            )
            await fetchMyResult()
            await authManager.fetchLeaderboard(contestId: contestIdLocal)
            await authManager.fetchContests()
            
            // Re-fetch badges in case the completed contest has ended and awarded a badge
            if let userId = authManager.currentUser?.id {
                await authManager.fetchBadges(userId: userId)
            }
        }
        
        trainingPhase = .summary
    }
    
    // MARK: - Contest Status Content
    var contestStatusContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                topBar
                contestHeader
                    .padding(.top, 8)
                problemCard
                    .padding(.top, 16)
                startExerciseButton
                    .padding(.top, 12)
                myStatusCard
                    .padding(.top, 12)
                standingsSection
                    .padding(.top, 16)
            }
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Start Exercise Button (goes directly to camera)
    var startExerciseButton: some View {
        VStack(spacing: 8) {
            if matchedCategory != nil {
                Button(action: startContestTraining) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16))
                        Text(myResult?.completed == true ? "Retry Exercise" : "Start Exercise")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Exercise \"\(contest.exerciseName)\" not found in library")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.main.text.opacity(0.5))
                }
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 16)
    }
    
    /// Set up performance with fixed contest parameters and go directly to pose detection
    private func startContestTraining() {
        guard let category = matchedCategory else { return }
        
        // Reset performance cleanly
        exercisePerformance.reinitialize()
        
        // Fixed parameters from contest — user cannot change these
        exercisePerformance.targetCount = contest.targetReps
        exercisePerformance.targetTime = nil
        exercisePerformance.feedback = true
        exercisePerformance.controller = category.exerciseAdjustment
        exercisePerformance.modelConfig = .init(
            detailedFaceTracking: category.detailedFaceTraking,
            detailedHandTracking: category.detailedHandTraking
        )
        
        // Skip .setting, go directly to .traning (camera)
        exercisePerformance.exerciseStatus = .traning
        trainingPhase = .training
    }
    
    // MARK: - Load Data
    private func loadContestData() async {
        if !contest.isJoined {
            await authManager.joinContest(contestId: contest.id)
        }
        await fetchMyResult()
        await authManager.fetchLeaderboard(contestId: contest.id)
        isLoading = false
    }
    
    private func fetchMyResult() async {
        guard let userId = authManager.currentUser?.id else { return }
        do {
            let results: [ContestParticipant] = try await supabase
                .from("contest_participants")
                .select("id, contest_id, user_id, accuracy, time_seconds, completed, joined_at, completed_at")
                .eq("contest_id", value: contest.id)
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            await MainActor.run {
                self.myResult = results.first
            }
        } catch {
            print("⚠️ Could not fetch my result: \(error)")
        }
    }
    
    // MARK: - Top Bar
    var topBar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Contests")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(theme.main.text.opacity(0.7))
            }
            Spacer()
            
            Button(action: {
                Task {
                    isLoading = true
                    await loadContestData()
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.main.text.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Contest Header
    var contestHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Text(contest.difficultyPoints)
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: contest.difficultyColor).opacity(0.2))
                    .foregroundColor(Color(hex: contest.difficultyColor))
                    .clipShape(Capsule())
                
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("+\(contest.pointsReward) pts")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.15))
                .foregroundColor(.yellow)
                .clipShape(Capsule())
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                    Text("×\(contest.participantCount)")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(theme.main.text.opacity(0.5))
            }
            .padding(.horizontal, 20)
            
            Text(contest.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(theme.main.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Problem Card
    var problemCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(accentColor)
                Text("Problem")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(theme.main.text)
            }
            
            Rectangle()
                .fill(theme.main.text.opacity(0.1))
                .frame(height: 1)
            
            if let desc = contest.description {
                Text(desc)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(theme.main.text.opacity(0.75))
                    .lineSpacing(4)
            }
            
            // Exercise preview images from category
            if let cat = matchedCategory, let firstImage = cat.images.first {
                HStack(spacing: 4) {
                    Image(firstImage.0)
                        .resizable()
                        .scaledToFit()
                    Image(firstImage.1)
                        .resizable()
                        .scaledToFit()
                }
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                taskRow(icon: "figure.strengthtraining.traditional", label: "Exercise", value: contest.exerciseName)
                taskRow(icon: "repeat", label: "Target Reps", value: "\(contest.targetReps)")
                taskRow(icon: "gauge.with.needle", label: "Judging", value: "Accuracy → Time (fastest)")
                taskRow(icon: "clock.fill", label: "Time Limit", value: "None")
                
                if let cat = matchedCategory {
                    taskRow(icon: "figure.run", label: "Muscle", value: cat.muscleGroup.displayName)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background { BlurView(style: theme.main.ultraThinMaterial) }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
    }
    
    private func taskRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(accentColor)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.main.text.opacity(0.5))
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(theme.main.text)
        }
    }
    
    // MARK: - My Status Card
    var myStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.blue)
                Text("My Submission")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(theme.main.text)
            }
            
            Rectangle()
                .fill(theme.main.text.opacity(0.1))
                .frame(height: 1)
            
            if isLoading {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .padding(.vertical, 12)
            } else if let result = myResult {
                HStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Image(systemName: result.completed == true ? "checkmark.circle.fill" : "clock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(result.completed == true ? .green : .orange)
                        Text(result.completed == true ? "Accepted" : "Pending")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(result.completed == true ? .green : .orange)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle().fill(theme.main.text.opacity(0.1)).frame(width: 1, height: 50)
                    
                    VStack(spacing: 4) {
                        if let acc = result.accuracy {
                            Text(String(format: "%.1f%%", acc))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(acc >= 90 ? .green : (acc >= 70 ? .yellow : .orange))
                        } else {
                            Text("—")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.3))
                        }
                        Text("Accuracy (PB)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.main.text.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle().fill(theme.main.text.opacity(0.1)).frame(width: 1, height: 50)
                    
                    VStack(spacing: 4) {
                        if let time = result.timeSeconds {
                            Text(String(format: "%.1fs", time))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(theme.main.text)
                        } else {
                            Text("—")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.3))
                        }
                        Text("Time")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.main.text.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                Text("You have not submitted yet.")
                    .font(.system(size: 13))
                    .foregroundColor(theme.main.text.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background { BlurView(style: theme.main.ultraThinMaterial) }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
    }
    
    // MARK: - Standings
    var standingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "list.number")
                    .foregroundColor(accentColor)
                Text("Standings")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(theme.main.text)
                Spacer()
                Text("\(authManager.leaderboard.count) solved")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.main.text.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            HStack(spacing: 0) {
                Text("#").frame(width: 36, alignment: .center)
                Text("Who").frame(maxWidth: .infinity, alignment: .leading)
                Text("Accuracy").frame(width: 80, alignment: .trailing)
                Text("Time").frame(width: 70, alignment: .trailing)
            }
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(theme.main.text.opacity(0.4))
            .textCase(.uppercase)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(theme.main.text.opacity(0.05))
            .padding(.horizontal, 16)
            
            if isLoading {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .padding(.vertical, 24)
            } else if authManager.leaderboard.isEmpty {
                VStack(spacing: 6) {
                    Text("No submissions yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.main.text.opacity(0.4))
                    Text("Be the first to solve this problem!")
                        .font(.system(size: 12))
                        .foregroundColor(theme.main.text.opacity(0.3))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(Array(authManager.leaderboard.enumerated()), id: \.element.id) { index, entry in
                    standingRow(rank: index + 1, entry: entry)
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Standing Row
    private func standingRow(rank: Int, entry: LeaderboardEntry) -> some View {
        let isMe = entry.userId == authManager.currentUser?.id.uuidString
        
        return HStack(spacing: 0) {
            Group {
                switch rank {
                case 1: Text("🥇")
                case 2: Text("🥈")
                case 3: Text("🥉")
                default: Text("\(rank)").foregroundColor(theme.main.text.opacity(0.6))
                }
            }
            .font(.system(size: rank <= 3 ? 18 : 14, weight: .bold, design: .rounded))
            .frame(width: 36, alignment: .center)
            
            HStack(spacing: 8) {
                if let avatarUrl = entry.profiles?.avatarUrl, let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Circle().fill(theme.main.text.opacity(0.1))
                        }
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(theme.main.text.opacity(0.3))
                        .frame(width: 28, height: 28)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.profiles?.name ?? "User")
                        .font(.system(size: 13, weight: isMe ? .bold : .medium))
                        .foregroundColor(isMe ? .blue : theme.main.text)
                        .lineLimit(1)
                    if let username = entry.profiles?.username, !username.isEmpty {
                        Text("@\(username)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.main.text.opacity(0.35))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let acc = entry.accuracy {
                Text(String(format: "%.1f%%", acc))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(acc >= 90 ? .green : (acc >= 70 ? .yellow : .orange))
                    .frame(width: 80, alignment: .trailing)
            } else {
                Text("—").frame(width: 80, alignment: .trailing)
                    .foregroundColor(theme.main.text.opacity(0.3))
            }
            
            if let time = entry.timeSeconds {
                Text(String(format: "%.1fs", time))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(theme.main.text.opacity(0.7))
                    .frame(width: 70, alignment: .trailing)
            } else {
                Text("—").frame(width: 70, alignment: .trailing)
                    .foregroundColor(theme.main.text.opacity(0.3))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background {
            if isMe { accentColor.opacity(0.08) }
            else if rank % 2 == 0 { theme.main.text.opacity(0.02) }
            else { Color.clear }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Training Phase Enum
enum ContestTrainingPhase: Equatable {
    case idle       // Contest status page
    case training   // Pose detection (camera)
    case summary    // Results
}

// MARK: - Contest Summary View (self-contained, replaces SummaryView for contests)
struct ContestSummaryView: View {
    @EnvironmentObject var theme: AppThemeController
    
    let contest: ContestModel
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    let onDone: () -> Void
    
    private var accuracy: Double {
        let total = exercisePerformance.totalCorrect + exercisePerformance.totalIncorrect
        return total > 0 ? (Double(exercisePerformance.totalCorrect) / Double(total)) * 100.0 : 0.0
    }
    
    private var accentColor: Color {
        Color(hex: contest.colorHex ?? contest.difficultyColor)
    }
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Trophy icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 100, height: 100)
                    Image(systemName: accuracy >= 70 ? "trophy.fill" : "flag.checkered")
                        .font(.system(size: 44))
                        .foregroundColor(accentColor)
                }
                .padding(.top, 40)
                
                Text("Contest Completed!")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
                
                Text(contest.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.main.text.opacity(0.6))
                
                // Results cards
                HStack(spacing: 12) {
                    resultCard(
                        title: "Correct",
                        value: "\(exercisePerformance.totalCorrect)",
                        subtitle: "of \(exercisePerformance.totalCorrect + exercisePerformance.totalIncorrect) reps",
                        color: .green
                    )
                    resultCard(
                        title: "Accuracy",
                        value: String(format: "%.1f%%", accuracy),
                        subtitle: accuracy >= 90 ? "Excellent!" : (accuracy >= 70 ? "Good" : "Keep trying"),
                        color: accuracy >= 90 ? .green : (accuracy >= 70 ? .yellow : .orange)
                    )
                    resultCard(
                        title: "Time",
                        value: "\(exercisePerformance.totalTime)s",
                        subtitle: "total",
                        color: .blue
                    )
                }
                .padding(.horizontal, 16)
                
                // Points earned
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("+\(contest.pointsReward) points earned!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.yellow.opacity(0.1))
                .clipShape(Capsule())
                
                Spacer()
                
                // Done button
                Button(action: onDone) {
                    Text("Back to Contest")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func resultCard(title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(theme.main.text.opacity(0.4))
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(color)
            Text(subtitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(theme.main.text.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background { BlurView(style: theme.main.ultraThinMaterial) }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
