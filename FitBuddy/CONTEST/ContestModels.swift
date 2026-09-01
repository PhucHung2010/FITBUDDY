//
//  ContestModels.swift
//  FitBuddy
//
//  Created by FitBuddy on 25/08/2025.
//

import Foundation

// MARK: - Contest (from get_active_contests RPC or direct table select)
struct Contest: Codable, Identifiable {
    let id: UUID
    let exerciseName: String
    let title: String
    let description: String
    let difficulty: String?
    let targetReps: Int?
    let targetTime: Int?
    let pointsReward: Int?
    let startsAt: String?
    let endsAt: String?
    let createdAt: String?
    let participantCount: Int?
    let userSubmitted: Bool?
    let userPoints: Int?
    let userAccuracy: Int?
    let userAttemptsCount: Int?
    let attemptsLeft: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case exerciseName = "exercise_name"
        case title
        case description
        case difficulty
        case targetReps = "target_reps"
        case targetTime = "target_time"
        case pointsReward = "points_reward"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case createdAt = "created_at"
        case participantCount = "participant_count"
        case userSubmitted = "user_submitted"
        case userPoints = "user_points"
        case userAccuracy = "user_accuracy"
        case userAttemptsCount = "user_attempts_count"
        case attemptsLeft = "attempts_left"
    }
    
    var maxAttempts: Int { 3 }
    
    var attemptsUsed: Int {
        userAttemptsCount ?? (userSubmitted == true ? 1 : 0)
    }
    
    var remainingTries: Int {
        attemptsLeft ?? max(0, maxAttempts - attemptsUsed)
    }
    
    var canAttempt: Bool {
        remainingTries > 0 && !isExpired
    }
    
    var isCompletedAllTries: Bool {
        remainingTries == 0 && isSubmitted
    }
    
    var difficultyLevel: ContestDifficulty {
        guard let diff = difficulty else { return .medium }
        return ContestDifficulty(rawValue: diff.lowercased()) ?? .medium
    }
    
    var safePointsReward: Int {
        pointsReward ?? 100
    }
    
    var safeParticipantCount: Int {
        participantCount ?? 0
    }
    
    var isSubmitted: Bool {
        userSubmitted ?? false
    }
    
    var endsAtDate: Date? {
        guard let endsAt = endsAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: endsAt)
    }
    
    var isExpired: Bool {
        guard let endDate = endsAtDate else { return false }
        return endDate < Date()
    }
    
    var timeRemainingText: String? {
        guard let endDate = endsAtDate else { return nil }
        let now = Date()
        guard endDate > now else { return "Expired" }
        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: endDate)
        if let days = diff.day, days > 0 {
            return "\(days)d \(diff.hour ?? 0)h left"
        } else if let hours = diff.hour, hours > 0 {
            return "\(hours)h \(diff.minute ?? 0)m left"
        } else if let minutes = diff.minute {
            return "\(minutes)m left"
        }
        return nil
    }
}

// MARK: - Contest Difficulty
enum ContestDifficulty: String, Codable {
    case easy
    case medium
    case hard
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var iconName: String {
        switch self {
        case .easy: return "flame"
        case .medium: return "flame.fill"
        case .hard: return "bolt.fill"
        }
    }
}

// MARK: - Attempt Result (from submit_contest_attempt RPC)
struct ContestAttemptResult: Codable {
    let success: Bool?
    let attemptsUsed: Int?
    let attemptsLeft: Int?
    let isBestScore: Bool?
    let pointsEarned: Int?
    
    enum CodingKeys: String, CodingKey {
        case success
        case attemptsUsed = "attempts_used"
        case attemptsLeft = "attempts_left"
        case isBestScore = "is_best_score"
        case pointsEarned = "points_earned"
    }
}

// MARK: - Leaderboard Entry (from contest_leaderboard view)
struct ContestLeaderboardEntry: Codable, Identifiable {
    var id: UUID { userId }
    let contestId: UUID
    let userId: UUID
    let username: String
    let avatarUrl: String?
    let totalCorrect: Int
    let accuracy: Int
    let pointsEarned: Int
    let totalTime: Int
    let attemptsCount: Int?
    let submittedAt: String?
    let rank: Int
    
    enum CodingKeys: String, CodingKey {
        case contestId = "contest_id"
        case userId = "user_id"
        case username
        case avatarUrl = "avatar_url"
        case totalCorrect = "total_correct"
        case accuracy
        case pointsEarned = "points_earned"
        case totalTime = "total_time"
        case attemptsCount = "attempts_count"
        case submittedAt = "submitted_at"
        case rank
    }
}

// MARK: - Global Ranking Entry (from global_contest_ranking view)
struct GlobalRankingEntry: Codable, Identifiable {
    var id: UUID { userId }
    let userId: UUID
    let username: String
    let avatarUrl: String?
    let totalPoints: Int
    let contestsCompleted: Int
    let avgAccuracy: Double
    let rank: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case avatarUrl = "avatar_url"
        case totalPoints = "total_points"
        case contestsCompleted = "contests_completed"
        case avgAccuracy = "avg_accuracy"
        case rank
    }
}
