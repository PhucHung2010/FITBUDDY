//
//  ChatView.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//

import SwiftUI
import Supabase

struct ChatView: View {
    let roomId: UUID
    let otherUser: SupabaseProfile
    let onBack: () -> Void
    
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var tabViewController: TabViewController
    
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading = true
    @State private var channel: RealtimeChannelV2? = nil
    @State private var chatTask: Task<Void, Never>? = nil
    
    private let chatService = ChatService()
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(theme.main.text)
                            .frame(width: 40, height: 40)
                            .neumorphicCircle()
                    }
                    
                    if !otherUser.avatarUrl.isEmpty {
                        AsyncImage(url: URL(string: otherUser.avatarUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                            } else {
                                defaultAvatar
                            }
                        }
                        .frame(width: 40, height: 40)
                        .neumorphicCircle()
                    } else {
                        defaultAvatar
                            .neumorphicCircle()
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(otherUser.username)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text)
                        Text("@\(otherUser.userId)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.25))
                    }
                    
                    Spacer()
                    
                    NeumorphicIndicatorDots(dotSize: 4, spacing: 3)
                }
                .padding(.horizontal, 16)
                .padding(.top, 48)
                .padding(.bottom, 12)
                .background(
                    Rectangle()
                        .fill(theme.appTheme == .light ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface)
                        .neumorphicCard(cornerRadius: 0, shadowRadius: 6, shadowDistance: 3)
                )
                
                // Chat Area
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { message in
                                    MessageBubble(message: message, isCurrentUser: message.senderId == userController.profile?.id)
                                        .id(message.id)
                                        .contextMenu {
                                            if message.senderId == userController.profile?.id {
                                                Button(role: .destructive) {
                                                    deleteMessage(id: message.id)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                }
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal)
                        }
                        .onAppear {
                            if let last = messages.last {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: messages.count) { _ in
                            if let last = messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                // Input Area — placed via safeAreaInset to avoid keyboard layout conflicts
                HStack(spacing: 12) {
                    TextField("Message...", text: $inputText, axis: .vertical)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(theme.main.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .neumorphicInset(cornerRadius: 22)
                        .lineLimit(1...4)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background {
                                if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Circle().fill(theme.accentGradient)
                                } else {
                                    Circle().fill(Color.gray.opacity(0.3))
                                }
                            }
                            .neumorphicCircle(isPressed: inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.9))
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .background(
                    Rectangle()
                        .fill(theme.appTheme == .light ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface)
                        .neumorphicCard(cornerRadius: 0, shadowRadius: 6, shadowDistance: -3)
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                tabViewController.showTabBar = false
            }
            setupChat()
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.2)) {
                tabViewController.showTabBar = true
            }
            chatTask?.cancel()
            let chan = self.channel
            self.channel = nil
            Task {
                await chan?.unsubscribe()
            }
        }
    }
    
    private var defaultAvatar: some View {
        Circle()
            .fill(theme.accentGradient)
            .frame(width: 40, height: 40)
            .overlay {
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
    }
    
    private func setupChat() {
        chatTask?.cancel()
        chatTask = Task {
            // Fetch existing
            let fetched = await chatService.fetchMessages(roomId: roomId)
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self.messages = fetched
                self.isLoading = false
            }
            
            // Subscribe real-time
            let chan = await chatService.subscribeToMessages(
                roomId: roomId,
                onMessage: { newMsg in
                    Task { @MainActor in
                        if !self.messages.contains(where: { $0.id == newMsg.id }) {
                            self.messages.append(newMsg)
                        }
                    }
                },
                onDelete: { deletedId in
                    Task { @MainActor in
                        self.messages.removeAll(where: { $0.id == deletedId })
                    }
                }
            )
            
            guard !Task.isCancelled else {
                Task { await chan.unsubscribe() }
                return
            }
            
            await MainActor.run {
                self.channel = chan
            }
        }
    }
    
    private func sendMessage() {
        let content = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        inputText = "" // Optimistic clear
        
        Task {
            let success = await chatService.sendMessage(roomId: roomId, content: content)
            guard success else { return }
            
            // Brief delay to allow Realtime V2 WebSocket to deliver first
            try? await Task.sleep(nanoseconds: 400_000_000)
            
            // Lightweight safety net: only check the single latest message if not in list
            if self.messages.last?.content != content {
                if let latest = await chatService.fetchLatestMessage(roomId: roomId) {
                    await MainActor.run {
                        if !self.messages.contains(where: { $0.id == latest.id }) {
                            self.messages.append(latest)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteMessage(id: UUID) {
        Task {
            _ = await chatService.deleteMessage(messageId: id)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    @EnvironmentObject var theme: AppThemeController
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: 50) }
            
            Text(message.content)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(isCurrentUser ? .white : theme.main.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    if isCurrentUser {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(theme.accentGradient)
                            .shadow(color: theme.accentColor.opacity(0.35), radius: 6, y: 3)
                    } else {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(theme.appTheme == .light ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface)
                            .neumorphicCard(cornerRadius: 18, shadowRadius: 4, shadowDistance: 2)
                    }
                }
            
            if !isCurrentUser { Spacer(minLength: 50) }
        }
    }
}
