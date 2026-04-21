import Foundation

struct FollowerModel: Codable, Identifiable, Equatable {
    var id: String { followerId + followingId }
    let followerId: String
    let followingId: String
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case followerId = "follower_id"
        case followingId = "following_id"
        case createdAt = "created_at"
    }
}

struct UserFollowStats: Codable {
    let followerCount: Int
    let followingCount: Int
    
    enum CodingKeys: String, CodingKey {
        case followerCount = "follower_count"
        case followingCount = "following_count"
    }
}

struct ChatRoom: Codable, Identifiable, Equatable {
    let id: String
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
    }
}

struct ChatMessage: Codable, Identifiable, Equatable {
    let id: String
    let roomId: String
    let senderId: String
    let content: String
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomId = "room_id"
        case senderId = "sender_id"
        case content
        case createdAt = "created_at"
    }
}

// Helper model to fetch room members alongside the room details
struct ChatRoomWithRecipient: Identifiable {
    var id: String { room.id }
    let room: ChatRoom
    let recipient: UserModel?
}

struct ChatParticipant: Codable, Equatable {
    let roomId: String
    let userId: String
    let joinedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case userId = "user_id"
        case joinedAt = "joined_at"
    }
}
