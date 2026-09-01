//
//  ChatService.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//

import Foundation
import Supabase

class ChatService {
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - Get or Create DM Room (RPC only — enforces mutual-follow at database level)
    func getOrCreateChatRoom(with otherUserId: UUID) async -> UUID? {
        do {
            let roomId: UUID = try await supabase
                .rpc("get_or_create_dm_room", params: ["other_user_id": otherUserId.uuidString])
                .execute()
                .value
            return roomId
        } catch {
            // No direct fallback — the RPC enforces mutual-follow and self-DM protection.
            // Bypassing it would allow creating rooms without mutual follow.
            print("[ChatService] get_or_create_dm_room failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Fetch Chat Rooms for Current User (1 request via RPC, with auto-retry)
    func fetchChatRooms(retryCount: Int = 1) async -> [ChatRoomPreview] {
        do {
            // Single RPC call replaces the old 1+(3×N) request loop
            struct ChatRoomRow: Codable {
                let roomId: UUID
                let otherUserId: UUID
                let otherUserUid: String?
                let otherUsername: String?
                let otherBio: String?
                let otherAvatar: String?
                let otherBg: String?
                let lastMsgId: UUID?
                let lastMsgContent: String?
                let lastMsgSender: UUID?
                let lastMsgAt: String?
                
                enum CodingKeys: String, CodingKey {
                    case roomId        = "room_id"
                    case otherUserId   = "other_user_id"
                    case otherUserUid  = "other_user_uid"
                    case otherUsername = "other_username"
                    case otherBio      = "other_bio"
                    case otherAvatar   = "other_avatar"
                    case otherBg       = "other_bg"
                    case lastMsgId     = "last_msg_id"
                    case lastMsgContent = "last_msg_content"
                    case lastMsgSender = "last_msg_sender"
                    case lastMsgAt     = "last_msg_at"
                }
            }
            
            let rows: [ChatRoomRow] = try await supabase
                .rpc("get_my_chat_rooms")
                .execute()
                .value
            
            return rows.map { row in
                let profile = SupabaseProfile(
                    id: row.otherUserId,
                    userId: row.otherUserUid ?? "",
                    username: row.otherUsername ?? "User",
                    bio: row.otherBio ?? "",
                    avatarUrl: row.otherAvatar ?? "",
                    backgroundUrl: row.otherBg ?? ""
                )
                
                let lastMessage: ChatMessage? = row.lastMsgId.map { msgId in
                    ChatMessage(
                        id: msgId,
                        roomId: row.roomId,
                        senderId: row.lastMsgSender ?? row.otherUserId,
                        content: row.lastMsgContent ?? "",
                        createdAt: row.lastMsgAt ?? ""
                    )
                }
                
                return ChatRoomPreview(id: row.roomId, otherUser: profile, lastMessage: lastMessage)
            }
            
        } catch {
            if retryCount > 0 {
                print("[ChatService] Network hiccup (\(error.localizedDescription)), retrying fetchChatRooms in 0.5s...")
                try? await Task.sleep(nanoseconds: 500_000_000)
                return await fetchChatRooms(retryCount: retryCount - 1)
            }
            print("Fetch chat rooms error: \(error)")
            return []
        }
    }

    
    // MARK: - Fetch Messages for Room
    func fetchMessages(roomId: UUID) async -> [ChatMessage] {
        do {
            let messages: [ChatMessage] = try await supabase
                .from("messages")
                .select()
                .eq("room_id", value: roomId.uuidString)
                .order("created_at", ascending: true)
                .execute()
                .value
            return messages
        } catch {
            print("Fetch messages error: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch Latest Message for Room (1 row lightweight check)
    func fetchLatestMessage(roomId: UUID) async -> ChatMessage? {
        do {
            let messages: [ChatMessage] = try await supabase
                .from("messages")
                .select()
                .eq("room_id", value: roomId.uuidString)
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
                .value
            return messages.first
        } catch {
            return nil
        }
    }
    
    // MARK: - Send Message
    func sendMessage(roomId: UUID, content: String) async -> Bool {
        do {
            let currentUserId = try await supabase.auth.session.user.id
            
            struct MessageInsert: Codable {
                let roomId: UUID
                let senderId: UUID
                let content: String
                
                enum CodingKeys: String, CodingKey {
                    case roomId = "room_id"
                    case senderId = "sender_id"
                    case content
                }
            }
            
            let msg = MessageInsert(roomId: roomId, senderId: currentUserId, content: content)
            
            try await supabase
                .from("messages")
                .insert(msg)
                .execute()
            return true
        } catch {
            print("Send message error: \(error)")
            return false
        }
    }
    
    // MARK: - Delete Message
    func deleteMessage(messageId: UUID) async -> Bool {
        do {
            try await supabase
                .from("messages")
                .delete()
                .eq("id", value: messageId.uuidString)
                .execute()
            return true
        } catch {
            print("Delete message error: \(error)")
            return false
        }
    }
    
    // MARK: - Subscribe to Messages (Realtime V2)
    func subscribeToMessages(roomId: UUID, onMessage: @escaping (ChatMessage) -> Void, onDelete: @escaping (UUID) -> Void) async -> RealtimeChannelV2 {
        let channelName = "chat-room-\(roomId.uuidString)"
        let channel = supabase.realtimeV2.channel(channelName)
        
        // INSERT listener — ChatMessage already defines snake_case CodingKeys
        let decoder = JSONDecoder()
        
        _ = channel.onPostgresChange(
            InsertAction.self,
            schema: "public",
            table: "messages",
            filter: "room_id=eq.\(roomId.uuidString)"
        ) { action in
            do {
                let chatMsg = try action.decodeRecord(as: ChatMessage.self, decoder: decoder)
                if chatMsg.roomId == roomId {
                    onMessage(chatMsg)
                }
            } catch {
                print("Realtime INSERT decode error: \(error)")
            }
        }
        
        // DELETE listener
        _ = channel.onPostgresChange(
            DeleteAction.self,
            schema: "public",
            table: "messages",
            filter: "room_id=eq.\(roomId.uuidString)"
        ) { action in
            // Extract the id from AnyJSON oldRecord
            if let anyId = action.oldRecord["id"],
               case .string(let idString) = anyId,
               let id = UUID(uuidString: idString) {
                onDelete(id)
            }
        }
        
        try? await channel.subscribeWithError()
        return channel
    }
}
