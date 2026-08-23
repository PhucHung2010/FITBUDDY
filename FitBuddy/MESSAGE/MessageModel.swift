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
}

// For UI presentation
struct ChatRoomPreview: Identifiable {
    let id: UUID
    let otherUser: SupabaseProfile
    let lastMessage: ChatMessage?
}
