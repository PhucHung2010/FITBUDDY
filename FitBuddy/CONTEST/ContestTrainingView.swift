//
//  ContestTrainingView.swift
//  FitBuddy
//
//  Created by FitBuddy on 25/08/2025.
//

import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI

struct ContestTrainingView: View {
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var userController: UserController
    
    let contest: Contest
    let category: Category?
    let onComplete: (Bool) -> Void
    
    @StateObject private var exercisePerformance = FitnessExercisePerformance()
    @State private var selectedCategory: Category?
    @State private var isSubmitting = false
    @State private var submissionSuccess = false
    @State private var submissionError: String? = nil
    @State private var isBestScore = true
    @State private var attemptsLeft = 0
    @State private var showResult = false
    @State private var earnedPoints = 0
    
    @State private var isPreparingModel = true
    
    var body: some View {
        ZStack {
            if showResult {
                resultOverlay
                    .transition(.scale.combined(with: .opacity))
            } else if isPreparingModel {
                // Model warm-up overlay — shown while TensorFlow Lite is loading
                ZStack {
                    AppBackground().ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(theme.accentColor)
                        Text("Preparing pose detection…")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.7))
                    }
                }
                .transition(.opacity)
            } else {
                ZStack(alignment: .topTrailing) {
                    TrainingView(
                        category: $selectedCategory,
                        exercisePerformance: exercisePerformance
                    )
                    
                    // Exit challenge button
                    Button(action: {
                        exercisePerformance.quickPose.stop()
                        exercisePerformance.reinitialize()
                        onComplete(false)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(Color.black.opacity(0.55)))
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: showResult)
        .animation(.easeInOut(duration: 0.3), value: isPreparingModel)
        .onAppear {
            prepareAndSetupExercise()
        }
        .onChange(of: exercisePerformance.exerciseStatus) { newStatus in
            if newStatus == .summary {
                // Halt camera & speech immediately upon workout completion
                exercisePerformance.quickPose.stop()
                TextSpeech.stop()
                
                // Auto-submit when exercise reaches summary
                Task {
                    await submitContestResult()
                }
            }
        }
        .onDisappear {
            exercisePerformance.quickPose.stop()
            TextSpeech.stop()
        }
    }
    
    // MARK: - Setup
    func prepareAndSetupExercise() {
        guard let cat = category else { return }
        selectedCategory = cat
        
        // 1. Lock parameters from being overwritten by CoreData
        exercisePerformance.keepAvailable = true
        
        // 2. Set the exercise controller and adjustments (angles, ROM, guard checks)
        exercisePerformance.controller = cat.exerciseAdjustment
        
        // 3. Set QuickPose tracking config
        let config = QuickPose.ModelConfig(
            detailedFaceTracking: cat.detailedFaceTraking,
            detailedHandTracking: cat.detailedHandTraking
        )
        exercisePerformance.modelConfig = config
        
        // 4. Apply contest-specific targets from Supabase
        exercisePerformance.targetCount = contest.targetReps
        exercisePerformance.targetTime = contest.targetTime
        
        // 5. Set standard camera and display parameters
        exercisePerformance.feedback = true
        exercisePerformance.frontCamera = true
        exercisePerformance.showArc = true
        exercisePerformance.frameRates = 60.0
        
        // 6. Reset score
        exercisePerformance.totalCorrect = 0
        exercisePerformance.totalIncorrect = 0
        exercisePerformance.totalTime = 0
        exercisePerformance.feedbackText = []
        
        // 7. Transition to training: PoseDetectionView will display 3s countdown & start QuickPose
        withAnimation {
            self.isPreparingModel = false
            self.exercisePerformance.exerciseStatus = .traning
        }
    }
    
    // MARK: - Auto Submit Result
    func submitContestResult() async {
        guard !isSubmitting else { return }
        
        var userId = userController.profile?.id
        if userId == nil {
            if let session = try? await SupabaseManager.shared.client.auth.session {
                userId = session.user.id
            }
        }
        
        guard let validUserId = userId else {
            print("[ContestTrainingView] ❌ No user profile or session found. User must be signed in to submit.")
            await MainActor.run {
                self.isSubmitting = false
                self.submissionSuccess = false
                self.submissionError = "Please sign in to submit your challenge results."
                self.showResult = true
            }
            return
        }
        
        isSubmitting = true
        submissionError = nil
        
        let totalCount = exercisePerformance.totalCorrect + exercisePerformance.totalIncorrect
        let accuracy = totalCount > 0
            ? Int(Double(exercisePerformance.totalCorrect) / Double(totalCount) * 100)
            : 0
        
        let effectiveTarget = max(1, contest.targetReps ?? 20)
        let completionRatio = min(1.0, Double(exercisePerformance.totalCorrect) / Double(effectiveTarget))
        let accuracyRatio = totalCount > 0 ? (Double(exercisePerformance.totalCorrect) / Double(totalCount)) : 0.0
        earnedPoints = Int(round(Double(contest.safePointsReward) * completionRatio * accuracyRatio))
        
        let result = await ContestService.shared.submitResult(
            contestId: contest.id,
            userId: validUserId,
            totalCorrect: exercisePerformance.totalCorrect,
            totalIncorrect: exercisePerformance.totalIncorrect,
            totalTime: exercisePerformance.totalTime,
            pointsReward: contest.safePointsReward,
            targetReps: contest.targetReps
        )
        
        await MainActor.run {
            self.isSubmitting = false
            self.submissionSuccess = result.success
            self.isBestScore = result.isBestScore
            self.attemptsLeft = result.attemptsLeft
            self.submissionError = result.error
            self.showResult = true
        }
    }
    
    // MARK: - Result Overlay
    var resultOverlay: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Trophy / Result Icon
                ZStack {
                    Circle()
                        .fill(submissionSuccess ? theme.accentGradient : LinearGradient(colors: [Color.red, Color.orange], startPoint: .top, endPoint: .bottom))
                        .frame(width: 90, height: 90)
                        .shadow(color: (submissionSuccess ? theme.accentColor : Color.red).opacity(0.4), radius: 14, y: 5)
                    
                    Image(systemName: submissionSuccess ? "trophy.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(submissionSuccess ? "Challenge Attempt Finished!" : "Submission Failed")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(theme.main.text)
                    
                    if submissionSuccess {
                        if isBestScore {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                Text("New Personal Best Score!")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.12))
                        } else {
                            Text("Previous best score retained on leaderboard")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.6))
                        }
                    }
                }
                
                if !submissionSuccess, let error = submissionError {
                    Text(error)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.red.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                if submissionSuccess {
                    // Stats Cards
                    VStack(spacing: 10) {
                        resultStatRow(icon: "flame.fill", label: "Points This Attempt", value: "\(earnedPoints) / \(contest.safePointsReward) pts", color: Color(red: 1.0, green: 0.72, blue: 0.12))
                        
                        let totalCount = exercisePerformance.totalCorrect + exercisePerformance.totalIncorrect
                        let accuracy = totalCount > 0 ? Int(Double(exercisePerformance.totalCorrect) / Double(totalCount) * 100) : 0
                        resultStatRow(icon: "target", label: "Form Accuracy", value: "\(accuracy)%", color: NeumorphicColors.dotGreen)
                        
                        let target = contest.targetReps ?? 20
                        resultStatRow(icon: "checkmark.circle.fill", label: "Reps Completed", value: "\(exercisePerformance.totalCorrect) / \(target) reps", color: NeumorphicColors.dotBlue)
                        
                        resultStatRow(icon: "clock.fill", label: "Time", value: "\(exercisePerformance.totalTime)s", color: theme.accentColor)
                        
                        Divider().opacity(0.3)
                        
                        resultStatRow(icon: "bolt.badge.clock.fill", label: "Tries Remaining", value: "\(attemptsLeft)/3", color: attemptsLeft > 0 ? theme.accentColor : theme.main.text.opacity(0.5))
                    }
                    .padding(18)
                    .neumorphicCard(cornerRadius: 22)
                    .padding(.horizontal, 28)
                }
                
                Spacer()
                
                // Action Buttons (Retry Submit, Next Try, or Back)
                VStack(spacing: 12) {
                    if !submissionSuccess {
                        // Retry Submission button if network disconnected
                        Button(action: {
                            Task {
                                await submitContestResult()
                            }
                        }) {
                            HStack(spacing: 8) {
                                if isSubmitting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                Text(isSubmitting ? "Submitting..." : "Retry Submission")
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(theme.accentGradient)
                            )
                            .shadow(color: theme.accentColor.opacity(0.35), radius: 6, y: 3)
                        }
                        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
                        .disabled(isSubmitting)
                    } else if attemptsLeft > 0 {
                        Button(action: {
                            showResult = false
                            prepareAndSetupExercise()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Try Again (\(attemptsLeft) \(attemptsLeft == 1 ? "try" : "tries") left)")
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(theme.accentGradient)
                            )
                            .shadow(color: theme.accentColor.opacity(0.35), radius: 6, y: 3)
                        }
                        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
                    }
                    
                    Button(action: {
                        exercisePerformance.reinitialize()
                        onComplete(submissionSuccess)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 15, weight: .bold))
                            Text("Back to Challenges")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(theme.main.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .neumorphicCard(cornerRadius: 20)
                    }
                    .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
            }
        }
    }
    
    // MARK: - Result Stat Row
    func resultStatRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.6))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(theme.main.text)
        }
        .padding(.vertical, 4)
    }
}
