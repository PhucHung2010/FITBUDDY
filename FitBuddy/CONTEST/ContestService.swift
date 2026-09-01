//
//  ContestService.swift
//  FitBuddy
//
//  Created by FitBuddy on 25/08/2025.
//

import Foundation
import Supabase

// MARK: - Cache Entry
private struct CacheEntry<T> {
    let data: T
    let timestamp: Date
    let ttl: TimeInterval
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > ttl
    }
}

// MARK: - Contest Service
class ContestService: ObservableObject {
    static let shared = ContestService()
    
    private let supabase = SupabaseManager.shared.client
    
    // Cache storage
    private var contestsCache: CacheEntry<[Contest]>?
    private var leaderboardCache: [UUID: CacheEntry<[ContestLeaderboardEntry]>] = [:]
    
    private let contestsCacheTTL: TimeInterval = 300   // 5 minutes
    private let leaderboardCacheTTL: TimeInterval = 120 // 2 minutes
    
    @Published var contests: [Contest] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private init() {}
    
    // MARK: - Fetch Active Contests (RPC with direct table fallback, no N+1)
    @MainActor
    func fetchActiveContests(userId: UUID?, forceRefresh: Bool = false) async {
        // Return cached if valid
        if !forceRefresh, let cache = contestsCache, !cache.isExpired {
            self.contests = cache.data
            return
        }
        
        isLoading = true
        error = nil
        
        // 1. Try RPC first if user is logged in
        if let userId = userId {
            do {
                let response: [Contest] = try await supabase
                    .rpc("get_active_contests", params: ["p_user_id": userId.uuidString])
                    .execute()
                    .value
                
                print("[ContestService] Successfully fetched \(response.count) contests via RPC")
                self.contests = response
                self.contestsCache = CacheEntry(data: response, timestamp: Date(), ttl: contestsCacheTTL)
                self.isLoading = false
                return
            } catch {
                print("[ContestService] RPC get_active_contests failed (\(error.localizedDescription)), falling back to direct table select...")
            }
        }
        
        // 2. Direct table fallback (fetches all active contests directly from `contests` table)
        do {
            let response: [Contest] = try await supabase
                .from("contests")
                .select()
                .eq("is_active", value: true)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("[ContestService] Successfully fetched \(response.count) contests directly from table")
            self.contests = response
            self.contestsCache = CacheEntry(data: response, timestamp: Date(), ttl: contestsCacheTTL)
        } catch {
            self.error = error.localizedDescription
            print("[ContestService] Direct table select error: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Submit Result (RPC with 3-tries limit & best-score preservation)
    struct SubmitAttemptParams: Encodable {
        let p_contest_id: String
        let p_total_correct: Int
        let p_total_incorrect: Int
        let p_accuracy: Int
        let p_total_time: Int
        let p_points_earned: Int
    }
    
    func submitResult(
        contestId: UUID,
        userId: UUID,
        totalCorrect: Int,
        totalIncorrect: Int,
        totalTime: Int,
        pointsReward: Int,
        targetReps: Int? = nil,
        retryCount: Int = 2
    ) async -> (success: Bool, isBestScore: Bool, attemptsLeft: Int, error: String?) {
        let totalCount = totalCorrect + totalIncorrect
        let accuracy = totalCount > 0 ? Int(Double(totalCorrect) / Double(totalCount) * 100) : 0
        
        // Balanced Scoring Formula:
        // completionRatio = min(1.0, correctReps / targetReps)
        // accuracyRatio = correctReps / totalAttemptedReps
        // pointsEarned = pointsReward * completionRatio * accuracyRatio
        let effectiveTarget = max(1, targetReps ?? 20)
        let completionRatio = min(1.0, Double(totalCorrect) / Double(effectiveTarget))
        let accuracyRatio = totalCount > 0 ? (Double(totalCorrect) / Double(totalCount)) : 0.0
        let pointsEarned = Int(round(Double(pointsReward) * completionRatio * accuracyRatio))
        
        // Submit via the secure submit_contest_attempt RPC (enforces 3-attempt limit & best-score preservation)
        do {
            let params = SubmitAttemptParams(
                p_contest_id: contestId.uuidString,
                p_total_correct: totalCorrect,
                p_total_incorrect: totalIncorrect,
                p_accuracy: accuracy,
                p_total_time: totalTime,
                p_points_earned: pointsEarned
            )
            
            let result: ContestAttemptResult = try await supabase
                .rpc("submit_contest_attempt", params: params)
                .execute()
                .value
            
            // Invalidate caches
            contestsCache = nil
            leaderboardCache[contestId] = nil
            globalRankingCache = nil
            
            print("[ContestService] ✅ submit_contest_attempt RPC successful! Points: \(pointsEarned)/\(pointsReward) (Reps: \(totalCorrect)/\(effectiveTarget)), Attempts left: \(result.attemptsLeft ?? 0), isBest: \(result.isBestScore ?? true)")
            return (true, result.isBestScore ?? true, result.attemptsLeft ?? 0, nil)
        } catch {
            if retryCount > 0 {
                print("[ContestService] ⚠️ Network issue during submission (\(error.localizedDescription)), reconnecting and retrying in 0.5s... (Remaining tries: \(retryCount))")
                try? await Task.sleep(nanoseconds: 500_000_000)
                return await submitResult(
                    contestId: contestId,
                    userId: userId,
                    totalCorrect: totalCorrect,
                    totalIncorrect: totalIncorrect,
                    totalTime: totalTime,
                    pointsReward: pointsReward,
                    targetReps: targetReps,
                    retryCount: retryCount - 1
                )
            }
            print("[ContestService] ❌ submitResult error: \(error.localizedDescription) - \(error)")
            return (false, false, 0, error.localizedDescription)
        }
    }
    
    // MARK: - Fetch Leaderboard (Single query via SQL view)
    func fetchLeaderboard(contestId: UUID, forceRefresh: Bool = false) async -> [ContestLeaderboardEntry] {
        // Return cached if valid
        if !forceRefresh, let cache = leaderboardCache[contestId], !cache.isExpired {
            return cache.data
        }
        
        do {
            let entries: [ContestLeaderboardEntry] = try await supabase
                .from("contest_leaderboard")
                .select()
                .eq("contest_id", value: contestId.uuidString)
                .order("rank")
                .execute()
                .value
            
            leaderboardCache[contestId] = CacheEntry(data: entries, timestamp: Date(), ttl: leaderboardCacheTTL)
            return entries
        } catch {
            print("[ContestService] fetchLeaderboard error: \(error)")
            return []
        }
    }
    
    private var globalRankingCache: CacheEntry<[GlobalRankingEntry]>?
    private let globalRankingCacheTTL: TimeInterval = 120 // 2 minutes
    
    // MARK: - Fetch Global Ranking (Single query via SQL view)
    func fetchGlobalRanking(forceRefresh: Bool = false) async -> [GlobalRankingEntry] {
        if !forceRefresh, let cache = globalRankingCache, !cache.isExpired {
            return cache.data
        }
        
        do {
            let entries: [GlobalRankingEntry] = try await supabase
                .from("global_contest_ranking")
                .select()
                .order("rank")
                .execute()
                .value
            
            globalRankingCache = CacheEntry(data: entries, timestamp: Date(), ttl: globalRankingCacheTTL)
            return entries
        } catch {
            print("[ContestService] fetchGlobalRanking error: \(error)")
            return []
        }
    }
    
    // MARK: - Invalidate All Caches
    func invalidateCaches() {
        contestsCache = nil
        leaderboardCache.removeAll()
        globalRankingCache = nil
    }
}
