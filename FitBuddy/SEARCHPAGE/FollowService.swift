//
//  FollowService.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//

import Foundation
import Supabase

struct FollowRow: Codable {
    let followerId: UUID
    let followingId: UUID
    
    enum CodingKeys: String, CodingKey {
        case followerId = "follower_id"
        case followingId = "following_id"
    }
}

struct ProfileFollowState {
    var isFollowing: Bool = false
    var isFollowedBy: Bool = false
    var isMutualFollow: Bool = false
    var followerCount: Int = 0
    var followingCount: Int = 0
}

class FollowService {
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - Fetch All Follow State (1 RPC request instead of 4 separate queries)
    func fetchProfileFollowState(targetId: UUID) async -> ProfileFollowState {
        // 1. Try high-performance consolidated RPC first (1 single roundtrip)
        struct FollowStateResult: Codable {
            let isFollowing: Bool
            let isFollowedBy: Bool?
            let isMutualFollow: Bool
            let followerCount: Int
            let followingCount: Int
            
            enum CodingKeys: String, CodingKey {
                case isFollowing = "is_following"
                case isFollowedBy = "is_followed_by"
                case isMutualFollow = "is_mutual_follow"
                case followerCount = "follower_count"
                case followingCount = "following_count"
            }
        }
        
        if let results: [FollowStateResult] = try? await supabase
            .rpc("get_profile_follow_state", params: ["target_user_id": targetId.uuidString])
            .execute()
            .value,
           let state = results.first {
            return ProfileFollowState(
                isFollowing: state.isFollowing,
                isFollowedBy: state.isFollowedBy ?? state.isMutualFollow,
                isMutualFollow: state.isMutualFollow,
                followerCount: state.followerCount,
                followingCount: state.followingCount
            )
        }
        
        // 2. Direct fallback (if RPC not yet created in Supabase)
        guard let currentUserId = try? await supabase.auth.session.user.id else {
            return ProfileFollowState()
        }
        
        async let followingCheck: [FollowRow] = (try? await supabase
            .from("follows")
            .select("follower_id, following_id")
            .eq("follower_id", value: currentUserId.uuidString)
            .eq("following_id", value: targetId.uuidString)
            .limit(1)
            .execute()
            .value) ?? []
            
        async let followedByCheck: [FollowRow] = (try? await supabase
            .from("follows")
            .select("follower_id, following_id")
            .eq("follower_id", value: targetId.uuidString)
            .eq("following_id", value: currentUserId.uuidString)
            .limit(1)
            .execute()
            .value) ?? []
            
        async let followers = getFollowerCount(userId: targetId)
        async let following = getFollowingCount(userId: targetId)
        
        let (iFollow, theyFollow, fCount, fListCount) = await (
            followingCheck, followedByCheck, followers, following
        )
        
        let isFollowing = !iFollow.isEmpty
        let isFollowedBy = !theyFollow.isEmpty
        
        return ProfileFollowState(
            isFollowing: isFollowing,
            isFollowedBy: isFollowedBy,
            isMutualFollow: isFollowing && isFollowedBy,
            followerCount: fCount,
            followingCount: fListCount
        )
    }
    
    // MARK: - Follow a user
    func followUser(followingId: UUID) async -> Bool {
        do {
            let currentUserId = try await supabase.auth.session.user.id
            let follow = FollowRow(followerId: currentUserId, followingId: followingId)
            try await supabase
                .from("follows")
                .insert(follow)
                .execute()
            return true
        } catch {
            print("Follow error: \(error)")
            return false
        }
    }
    
    // MARK: - Unfollow a user
    func unfollowUser(followingId: UUID) async -> Bool {
        do {
            let currentUserId = try await supabase.auth.session.user.id
            try await supabase
                .from("follows")
                .delete()
                .eq("follower_id", value: currentUserId.uuidString)
                .eq("following_id", value: followingId.uuidString)
                .execute()
            return true
        } catch {
            print("Unfollow error: \(error)")
            return false
        }
    }
    
    // MARK: - Check if current user follows target
    func checkIfFollowing(targetId: UUID) async -> Bool {
        do {
            let currentUserId = try await supabase.auth.session.user.id
            let results: [FollowRow] = try await supabase
                .from("follows")
                .select("follower_id, following_id")
                .eq("follower_id", value: currentUserId.uuidString)
                .eq("following_id", value: targetId.uuidString)
                .limit(1)
                .execute()
                .value
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Check mutual follow (friends)
    func checkMutualFollow(otherUserId: UUID) async -> Bool {
        do {
            let currentUserId = try await supabase.auth.session.user.id
            // Try database RPC check_mutual_follow first
            if let isMutual: Bool = try? await supabase
                .rpc("check_mutual_follow", params: [
                    "user_a": currentUserId.uuidString,
                    "user_b": otherUserId.uuidString
                ])
                .execute()
                .value {
                return isMutual
            }
            
            // Fallback direct concurrent check
            async let q1: [FollowRow] = (try? await supabase
                .from("follows")
                .select("follower_id, following_id")
                .eq("follower_id", value: currentUserId.uuidString)
                .eq("following_id", value: otherUserId.uuidString)
                .limit(1)
                .execute().value) ?? []
                
            async let q2: [FollowRow] = (try? await supabase
                .from("follows")
                .select("follower_id, following_id")
                .eq("follower_id", value: otherUserId.uuidString)
                .eq("following_id", value: currentUserId.uuidString)
                .limit(1)
                .execute().value) ?? []
                
            let (r1, r2) = await (q1, q2)
            return !r1.isEmpty && !r2.isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Get follower count
    func getFollowerCount(userId: UUID) async -> Int {
        do {
            let response = try await supabase
                .from("follows")
                .select("follower_id", head: false, count: .exact)
                .eq("following_id", value: userId.uuidString)
                .execute()
            return response.count ?? 0
        } catch {
            return 0
        }
    }
    
    // MARK: - Get following count
    func getFollowingCount(userId: UUID) async -> Int {
        do {
            let response = try await supabase
                .from("follows")
                .select("following_id", head: false, count: .exact)
                .eq("follower_id", value: userId.uuidString)
                .execute()
            return response.count ?? 0
        } catch {
            return 0
        }
    }
}
