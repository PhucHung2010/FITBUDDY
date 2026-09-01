//
//  MessageModel.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//

import Foundation

struct ChatRoom: Codable, Identifiable {
    let id: UUID
    var createdAt: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
    }
}

struct ChatMember: Codable {
    let roomId: UUID
    let userId: UUID
    var joinedAt: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case userId = "user_id"
        case joinedAt = "joined_at"
    }
}

struct ChatMemberInsert: Codable {
    let roomId: UUID
    let userId: UUID
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case userId = "user_id"
    }
}

struct ChatMessage: Codable, Identifiable, Equatable {
    let id: UUID
    let roomId: UUID
    let senderId: UUID
    let content: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomId = "room_id"
        case senderId = "sender_id"
        case content
        case createdAt = "created_at"
    }
    
    init(id: UUID, roomId: UUID, senderId: UUID, content: String, createdAt: String = "") {
        self.id = id
        self.roomId = roomId
        self.senderId = senderId
        self.content = content
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.roomId = try container.decode(UUID.self, forKey: .roomId)
        self.senderId = try container.decode(UUID.self, forKey: .senderId)
        self.content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    }
}

// For UI presentation
struct ChatRoomPreview: Identifiable {
    let id: UUID
    let otherUser: SupabaseProfile
    let lastMessage: ChatMessage?
}
