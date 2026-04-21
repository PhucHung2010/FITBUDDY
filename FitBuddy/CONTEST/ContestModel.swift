//
//  ContestModel.swift
//  FitBuddy
//
//  Live contest models backed by Supabase.
//

import Foundation

// MARK: - Contest Model (matches 'contests' table)
struct ContestModel: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String?
    let exerciseName: String
    let targetReps: Int
    let difficulty: String
    let pointsReward: Int
    let iconSystemName: String?
    let colorHex: String?
    let startDate: String?
    let endDate: String?
    let createdAt: String?
    
    // Local only (not decoded from DB)
    var participantCount: Int = 0
    var isJoined: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case exerciseName = "exercise_name"
        case targetReps = "target_reps"
        case difficulty
        case pointsReward = "points_reward"
        case iconSystemName = "icon_system_name"
        case colorHex = "color_hex"
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
    }
    
    var difficultyColor: String {
        switch difficulty {
        case "hard": return "#FF5722"
        case "medium": return "#FFC107"
        default: return "#4CAF50"
        }
    }
    
    var difficultyPoints: String {
        switch difficulty {
        case "hard": return "🔥 Hard"
        case "medium": return "⚡ Medium"
        default: return "🌱 Easy"
        }
    }
}

// MARK: - Contest Participant (matches 'contest_participants' table)
struct ContestParticipant: Codable, Identifiable, Equatable {
    let id: String
    let contestId: String
    let userId: String
    var accuracy: Double?
    var timeSeconds: Double?
    var completed: Bool?
    let joinedAt: String?
    var completedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case contestId = "contest_id"
        case userId = "user_id"
        case accuracy
        case timeSeconds = "time_seconds"
        case completed
        case joinedAt = "joined_at"
        case completedAt = "completed_at"
    }
}

// MARK: - Leaderboard Entry (for joined query display)
struct LeaderboardEntry: Codable, Identifiable, Equatable {
    let id: String
    let contestId: String
    let userId: String
    var accuracy: Double?
    var timeSeconds: Double?
    var completed: Bool?
    
    // Profile data (joined via foreign key)
    let profiles: LeaderboardProfile?
    
    enum CodingKeys: String, CodingKey {
        case id
        case contestId = "contest_id"
        case userId = "user_id"
        case accuracy
        case timeSeconds = "time_seconds"
        case completed
        case profiles
    }
}

struct LeaderboardProfile: Codable, Equatable {
    let name: String?
    let username: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case username
        case avatarUrl = "avatar_url"
    }
}

// MARK: - Badge Model (matches 'user_badges' view)
struct BadgeModel: Codable, Identifiable, Equatable {
    var id: String { contestId } // UUID represented as String
    let contestId: String
    let userId: String
    let contestTitle: String
    let rank: Int
    
    enum CodingKeys: String, CodingKey {
        case contestId = "contest_id"
        case userId = "user_id"
        case contestTitle = "contest_title"
        case rank
    }
}
