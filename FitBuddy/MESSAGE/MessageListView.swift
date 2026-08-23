//
//  MessageListView.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//

import SwiftUI

struct MessageListView: View {
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var tabViewController: TabViewController
    
    @State private var chatRooms: [ChatRoomPreview] = []
    @State private var isLoading = true
    @State private var selectedRoomId: UUID? = nil
    @State private var selectedProfile: SupabaseProfile? = nil
    
    private let chatService = ChatService()
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            VStack(spacing: 0) {
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if chatRooms.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 46))
                            .foregroundColor(theme.main.text.opacity(0.3))
                        Text("No messages yet")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.6))
                        Text("Follow friends to start chatting")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.45))
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 24)
                    .neumorphicCard(cornerRadius: 24)
                    .padding(.horizontal, 20)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(chatRooms) { room in
                                ChatRoomRow(preview: room)
                                    .onTapGesture {
                                        selectedProfile = room.otherUser
                                        selectedRoomId = room.id
                                    }
                            }
                        }
                        .padding(.top, 14)
                        .padding(.horizontal, 16)
                        
                        Spacer().frame(height: 100)
                    }
                    .refreshable {
                        await fetchRooms()
                    }
                }
            }
            
            // Navigation to Chat View
            if let roomId = selectedRoomId, let profile = selectedProfile {
                ChatView(
                    roomId: roomId,
                    otherUser: profile,
                    onBack: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                            selectedRoomId = nil
                            selectedProfile = nil
                        }
                        // Refresh to update last message preview
                        Task { await fetchRooms() }
                    }
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .onAppear {
            Task {
                await fetchRooms()
            }
        }
    }
    
    private func fetchRooms() async {
        await MainActor.run { isLoading = true }
        let rooms = await chatService.fetchChatRooms()
        await MainActor.run {
            chatRooms = rooms
            isLoading = false
        }
    }
}

struct ChatRoomRow: View {
    let preview: ChatRoomPreview
    @EnvironmentObject var theme: AppThemeController
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            if !preview.otherUser.avatarUrl.isEmpty {
                AsyncImage(url: URL(string: preview.otherUser.avatarUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } else {
                        defaultAvatar
                    }
                }
                .frame(width: 52, height: 52)
                .neumorphicCircle()
            } else {
                defaultAvatar
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(preview.otherUser.username)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text)
                    Spacer()
                    if let msg = preview.lastMessage, let date = dateFromString(msg.createdAt) {
                        Text(timeAgo(from: date))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.45))
                    }
                }
                
                if let msg = preview.lastMessage {
                    Text(msg.content)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(theme.main.text.opacity(0.65))
                        .lineLimit(1)
                } else {
                    Text("Start a conversation")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.25))
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(theme.main.text.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .neumorphicCard(cornerRadius: 22)
    }
    
    private var defaultAvatar: some View {
        Circle()
            .fill(theme.accentGradient)
            .frame(width: 52, height: 52)
            .overlay {
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 22))
            }
            .neumorphicCircle()
    }
    
    // Simple date formatter helpers
    private func dateFromString(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string) ?? ISO8601DateFormatter().date(from: string)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
