//
//  ContestView.swift
//  FitBuddy
//
//  Live contest list backed by Supabase.
//

import SwiftUI
import Foundation

struct ContestView: View {
    @EnvironmentObject var authManager: SupabaseAuthManager
    @EnvironmentObject var theme: AppThemeController
    @State private var selectedContest: ContestModel? = nil
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Contests")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(theme.main.text)
                            Text("Compete with others, earn points & badges")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(theme.main.text.opacity(0.6))
                        }
                        Spacer()
                        
                        // User points display
                        if let points = authManager.currentUserProfile?.points, points > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(points)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(theme.main.text)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background { BlurView(style: theme.main.ultraThinMaterial) }
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    if authManager.contests.isEmpty {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading contests...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.main.text.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        ForEach(authManager.contests) { contest in
                            ContestCard(contest: contest, theme: theme) {
                                selectedContest = contest
                            } onJoin: {
                                selectedContest = contest
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .sheet(item: $selectedContest) { contest in
            ContestStatusView(contest: contest)
        }
        .task {
            await authManager.fetchContests()
        }
    }
}

// MARK: - Contest Card
struct ContestCard: View {
    let contest: ContestModel
    let theme: AppThemeController
    let onTap: () -> Void
    let onJoin: () -> Void
    
    private var accentColor: Color {
        Color(hex: contest.colorHex ?? contest.difficultyColor)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: icon + title + difficulty
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: contest.iconSystemName ?? "trophy.fill")
                        .font(.system(size: 22))
                        .foregroundColor(accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(contest.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text)
                        .lineLimit(1)
                    
                    Text(contest.difficultyPoints)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: contest.difficultyColor))
                }
                
                Spacer()
                
                // Points badge
                VStack(spacing: 2) {
                    Text("+\(contest.pointsReward)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                    Text("pts")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.main.text.opacity(0.5))
                }
            }
            
            // Exercise task
            HStack(spacing: 6) {
                Image(systemName: "figure.run")
                    .font(.system(size: 13))
                    .foregroundColor(accentColor)
                Text("\(contest.exerciseName) · \(contest.targetReps) reps")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.main.text.opacity(0.8))
            }
            
            if let desc = contest.description {
                Text(desc)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(theme.main.text.opacity(0.6))
                    .lineLimit(2)
            }
            
            // Bottom row: participants + join button
            HStack {
                // Participants
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 13))
                        .foregroundColor(theme.main.text.opacity(0.5))
                    Text("\(contest.participantCount) joined")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.main.text.opacity(0.5))
                }
                
                Spacer()
                
                if contest.isJoined {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Joined")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background { BlurView(style: theme.main.ultraThinMaterial) }
                    .clipShape(Capsule())
                } else {
                    Button(action: onJoin) {
                        Text("Join")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(accentColor)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background { BlurView(style: theme.main.ultraThinMaterial) }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { onTap() }
    }
}


