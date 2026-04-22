import Foundation
import Supabase

@MainActor
class SocialManager: ObservableObject {
    @Published var selectedUser: UserModel?
    @Published var searchResults: [UserModel] = []
    @Published var selectedUserFollowStats: UserFollowStats?
    @Published var isFollowingSelectedUser: Bool = false
    
    // Chat Data
    @Published var myChatRooms: [ChatRoomWithRecipient] = []
    @Published var currentRoomMessages: [ChatMessage] = []
    
    private var messageSubscriptionTask: Task<Void, Never>?
    private var isPolling: Bool = false
    
    // MARK: - Follow System
    
    func searchUsers(query: String) async {
        guard !query.isEmpty else {
            self.searchResults = []
            return
        }
        
        do {
            let users: [UserModel] = try await supabase
                .from("profiles")
                .select()
                .ilike("email", value: "%\(query)%")
                .limit(20)
                .execute()
                .value
            
            self.searchResults = users
        } catch {
            print("Failed to search users: \(error)")
        }
    }
    
    func fetchUserProfileData(userId: String, currentUserId: String) async {
        do {
            // Fetch stats
            let stats: [UserFollowStats] = try await supabase
                .from("user_follow_stats")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            if let first = stats.first {
                self.selectedUserFollowStats = first
            } else {
                self.selectedUserFollowStats = UserFollowStats(followerCount: 0, followingCount: 0)
            }
            
            // Check following status
            let isFollowing: [FollowerModel] = try await supabase
                .from("followers")
                .select()
                .eq("follower_id", value: currentUserId)
                .eq("following_id", value: userId)
                .execute()
                .value
            
            self.isFollowingSelectedUser = !isFollowing.isEmpty
        } catch {
            print("Failed to fetch user profile data: \(error)")
        }
    }
    
    func toggleFollow(currentUserId: String, targetUserId: String) async {
        let isCurrentlyFollowing = self.isFollowingSelectedUser
        
        do {
            if isCurrentlyFollowing {
                // Unfollow
                try await supabase
                    .from("followers")
                    .delete()
                    .eq("follower_id", value: currentUserId)
                    .eq("following_id", value: targetUserId)
                    .execute()
                self.isFollowingSelectedUser = false
                if let old = self.selectedUserFollowStats {
                    self.selectedUserFollowStats = UserFollowStats(followerCount: max(0, old.followerCount - 1), followingCount: old.followingCount)
                }
            } else {
                // Follow
                let insertData = ["follower_id": currentUserId, "following_id": targetUserId]
                try await supabase
                    .from("followers")
                    .insert(insertData)
                    .execute()
                self.isFollowingSelectedUser = true
                if let old = self.selectedUserFollowStats {
                    self.selectedUserFollowStats = UserFollowStats(followerCount: old.followerCount + 1, followingCount: old.followingCount)
                }
            }
        } catch {
            print("Failed to toggle follow: \(error)")
        }
    }
    
    // MARK: - Chat System
    
    func loadMyChatRooms(currentUserId: String) async {
        do {
            // First get room IDs where current user is a participant
            let myParticipations: [ChatParticipant] = try await supabase
                .from("chat_participants")
                .select()
                .eq("user_id", value: currentUserId)
                .execute()
                .value
            
            if myParticipations.isEmpty {
                self.myChatRooms = []
                return
            }
            
            let roomIds = myParticipations.map { $0.roomId }
            
            // Fetch all participants in those rooms to find the other user
            let allParticipants: [ChatParticipant] = try await supabase
                .from("chat_participants")
                .select()
                .in("room_id", values: roomIds)
                .neq("user_id", value: currentUserId) // Get the OTHER person
                .execute()
                .value
            
            // Fetch the room details
            let rooms: [ChatRoom] = try await supabase
                .from("chat_rooms")
                .select()
                .in("id", values: roomIds)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            // Fetch other user profiles
            let otherUserIds = allParticipants.map { $0.userId }
            var profiles: [UserModel] = []
            if !otherUserIds.isEmpty {
                profiles = try await supabase
                    .from("profiles")
                    .select()
                    .in("id", values: otherUserIds)
                    .execute()
                    .value
            }
            
            // Stitch together
            var assembledRooms: [ChatRoomWithRecipient] = []
            for room in rooms {
                let participant = allParticipants.first(where: { $0.roomId == room.id })
                let recipient = profiles.first(where: { $0.id == participant?.userId })
                assembledRooms.append(ChatRoomWithRecipient(room: room, recipient: recipient))
            }
            
            self.myChatRooms = assembledRooms
        } catch {
            print("Failed to load chat rooms: \(error)")
        }
    }
    
    func getOrCreateChatRoom(currentUserId: String, targetUserId: String) async -> String? {
        // Optimization: if they already have a room, return it.
        // We know they have a room if finding intersection of their joined rooms.
        do {
            let myRooms: [ChatParticipant] = try await supabase
                .from("chat_participants")
                .select("room_id")
                .eq("user_id", value: currentUserId)
                .execute()
                .value
                
            let targetRooms: [ChatParticipant] = try await supabase
                .from("chat_participants")
                .select("room_id")
                .eq("user_id", value: targetUserId)
                .execute()
                .value
            
            let myRoomSet = Set(myRooms.map { $0.roomId })
            let targetRoomSet = Set(targetRooms.map { $0.roomId })
            let intersection = myRoomSet.intersection(targetRoomSet)
            
            if let commonRoomId = intersection.first {
                return commonRoomId
            }
            
            // Create a new room with a client-generated UUID
            let newRoomId = UUID().uuidString.lowercased()
            try await supabase
                .from("chat_rooms")
                .insert(["id": newRoomId])
                .execute()
            
            // Insert participants
            try await supabase
                .from("chat_participants")
                .insert([
                    ["room_id": newRoomId, "user_id": currentUserId],
                    ["room_id": newRoomId, "user_id": targetUserId]
                ])
                .execute()
                
            return newRoomId
            
        } catch {
            print("Failed creating chat room: \(error)")
            return nil
        }
    }
    
    func subscribeToMessages(roomId: String) {
        stopListening()
        isPolling = true
        
        messageSubscriptionTask = Task {
            while isPolling && !Task.isCancelled {
                do {
                    let messages: [ChatMessage] = try await supabase
                        .from("chat_messages")
                        .select()
                        .eq("room_id", value: roomId)
                        .order("created_at", ascending: true)
                        .execute()
                        .value
                    
                    await MainActor.run {
                        if self.currentRoomMessages != messages {
                            self.currentRoomMessages = messages
                        }
                    }
                } catch {
                    if !Task.isCancelled {
                        print("Fetch msg failed: \(error)")
                    }
                }
                
                // Sleep 2 seconds before next poll
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }
    
    func stopListening() {
        isPolling = false
        messageSubscriptionTask?.cancel()
        messageSubscriptionTask = nil
    }
    
    func sendMessage(roomId: String, senderId: String, content: String) async {
        guard !content.isEmpty else { return }
        
        let msg = [
            "room_id": roomId,
            "sender_id": senderId,
            "content": content
        ]
        
        do {
            try await supabase
                .from("chat_messages")
                .insert(msg)
                .execute()
        } catch {
            print("Failed sending message: \(error)")
        }
    }
}
