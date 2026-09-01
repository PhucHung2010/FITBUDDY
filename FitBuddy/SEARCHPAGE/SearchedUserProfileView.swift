//
//  SearchedUserProfileView.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//

import SwiftUI

struct SearchedUserProfileView: View {
    let profile: SupabaseProfile
    let onBack: () -> Void
    
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var tabController: TabViewController
    @EnvironmentObject var userController: UserController
    
    var isOwnProfile: Bool {
        userController.profile?.id == profile.id
    }
    
    @State private var isFollowing = false
    @State private var isFollowedBy = false
    @State private var isMutualFollow = false
    @State private var followerCount = 0
    @State private var followingCount = 0
    @State private var isLoadingFollow = true
    @State private var isOpeningChat = false
    @State private var activeChatRoomId: UUID? = nil
    
    private let followService = FollowService()
    private let chatService = ChatService()
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Area
                    ZStack(alignment: .bottom) {
                        // Background Cover
                        if !profile.backgroundUrl.isEmpty {
                            AsyncImage(url: URL(string: profile.backgroundUrl)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    theme.accentGradient
                                }
                            }
                            .frame(height: 190)
                            .clipped()
                        } else {
                            theme.accentGradient
                                .frame(height: 190)
                        }
                        
                        // Back Button inside Header (ONLY when viewing other users from search, NEVER on own profile)
                        if !isOwnProfile {
                            HStack {
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                                        onBack()
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(theme.main.text)
                                        .frame(width: 42, height: 42)
                                        .neumorphicCircle()
                                }
                                Spacer()
                            }
                            .padding(.top, 50)
                            .padding(.leading, 16)
                            .frame(maxHeight: .infinity, alignment: .topLeading)
                        }
                        
                        // Avatar
                        if !profile.avatarUrl.isEmpty {
                            AsyncImage(url: URL(string: profile.avatarUrl)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                } else {
                                    defaultAvatar
                                }
                            }
                            .frame(width: 110, height: 110)
                            .neumorphicCircle(shadowRadius: 10, shadowDistance: 5)
                            .offset(y: 55)
                        } else {
                            defaultAvatar
                                .neumorphicCircle(shadowRadius: 10, shadowDistance: 5)
                                .offset(y: 55)
                        }
                    }
                    .padding(.bottom, 65)
                    
                    // Info Card Container
                    VStack(spacing: 12) {
                        Text(profile.username)
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(theme.main.text)
                        
                        Text("@\(profile.userId)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(theme.accentColor)
                        
                        // Stats Wells
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("\(followerCount)")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundColor(theme.main.text)
                                Text("Followers")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.main.text.opacity(0.45))
                            }
                            .frame(width: 110, height: 60)
                            .neumorphicInset(cornerRadius: 16)
                            
                            VStack(spacing: 4) {
                                Text("\(followingCount)")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundColor(theme.main.text)
                                Text("Following")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(theme.main.text.opacity(0.45))
                            }
                            .frame(width: 110, height: 60)
                            .neumorphicInset(cornerRadius: 16)
                        }
                        .padding(.vertical, 8)
                        
                        if !profile.bio.isEmpty {
                            Text(profile.bio)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)
                        }
                        
                        if isOwnProfile {
                            HStack(spacing: 8) {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                                    .foregroundColor(theme.accentColor)
                                Text("This is your profile")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.main.text)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .neumorphicCard(cornerRadius: 20)
                            .padding(.top, 8)
                        } else {
                            // Action Buttons
                            HStack(spacing: 14) {
                                // Follow Button
                                Button(action: toggleFollow) {
                                    Text(isFollowing ? "Following" : "Follow")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(isFollowing ? theme.main.text : .white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background {
                                            if !isFollowing {
                                                Capsule().fill(theme.accentGradient)
                                            }
                                        }
                                        .neumorphicPill(gradient: isFollowing ? nil : theme.accentGradient, isPressed: isFollowing)
                                }
                                .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
                                .disabled(isLoadingFollow)
                                
                                // Message Button
                                Button(action: openChat) {
                                    if isOpeningChat {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .frame(width: 48, height: 48)
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(isMutualFollow ? .white : theme.main.text.opacity(0.3))
                                            .frame(width: 48, height: 48)
                                            .background {
                                                if isMutualFollow {
                                                    Circle().fill(theme.accentGradient)
                                                }
                                            }
                                            .neumorphicCircle(isPressed: !isMutualFollow)
                                    }
                                }
                                .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.9))
                                .disabled(!isMutualFollow || isOpeningChat)
                                .opacity(isMutualFollow ? 1.0 : 0.5)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            
                            if !isMutualFollow && isFollowing {
                                Text("Waiting for them to follow back to message")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(theme.main.text.opacity(0.45))
                                    .padding(.top, 2)
                            } else if !isMutualFollow {
                                Text("Follow each other to message")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(theme.main.text.opacity(0.45))
                                    .padding(.top, 2)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .neumorphicCard(cornerRadius: 28)
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 100)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Direct Chat View Navigation Overlay
            if let roomId = activeChatRoomId {
                ChatView(
                    roomId: roomId,
                    otherUser: profile,
                    onBack: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                            activeChatRoomId = nil
                        }
                    }
                )
                .transition(.move(edge: .trailing))
                .zIndex(2)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                tabController.showTabBar = false
            }
            loadFollowData()
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.2)) {
                tabController.showTabBar = true
            }
        }
    }
    
    private var defaultAvatar: some View {
        Circle()
            .fill(theme.accentGradient)
            .frame(width: 120, height: 120)
            .overlay {
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 55))
            }
    }
    
    private func loadFollowData() {
        isLoadingFollow = true
        Task {
            let state = await followService.fetchProfileFollowState(targetId: profile.id)
            await MainActor.run {
                self.isFollowing = state.isFollowing
                self.isFollowedBy = state.isFollowedBy
                self.isMutualFollow = state.isMutualFollow
                self.followerCount = state.followerCount
                self.followingCount = state.followingCount
                self.isLoadingFollow = false
            }
        }
    }
    
    private func toggleFollow() {
        let wasFollowing = isFollowing
        let newFollowing = !wasFollowing
        
        // Optimistic UI update — mutual status derived instantly from isFollowedBy
        isFollowing = newFollowing
        followerCount = max(0, followerCount + (newFollowing ? 1 : -1))
        isMutualFollow = newFollowing && isFollowedBy
        
        Task {
            let success = newFollowing ?
                await followService.followUser(followingId: profile.id) :
                await followService.unfollowUser(followingId: profile.id)
            
            if !success {
                // Revert on network failure
                await MainActor.run {
                    self.isFollowing = wasFollowing
                    self.isMutualFollow = wasFollowing && self.isFollowedBy
                    self.followerCount = max(0, self.followerCount + (wasFollowing ? 1 : -1))
                }
            }
        }
    }
    
    private func openChat() {
        guard isMutualFollow, !isOpeningChat else { return }
        isOpeningChat = true
        Task {
            if let roomId = await chatService.getOrCreateChatRoom(with: profile.id) {
                await MainActor.run {
                    self.isOpeningChat = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                        self.activeChatRoomId = roomId
                    }
                }
            } else {
                await MainActor.run {
                    self.isOpeningChat = false
                }
            }
        }
    }
}
