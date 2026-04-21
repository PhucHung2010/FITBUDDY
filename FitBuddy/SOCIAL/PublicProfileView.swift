import SwiftUI

struct PublicProfileView: View {
    let user: UserModel
    @EnvironmentObject var authManager: SupabaseAuthManager
    @EnvironmentObject var socialManager: SocialManager
    @EnvironmentObject var theme: AppThemeController
    
    @State private var externalUserBadges: [BadgeModel] = []
    @State private var navigateToChat: Bool = false
    @State private var commonRoomId: String? = nil
    @State private var isCreatingRoom: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            theme.main.mainColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header custom
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(theme.main.text)
                    }
                    Spacer()
                    Text(user.username ?? "Profile")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(theme.main.text)
                    Spacer()
                    // balancer
                    Image(systemName: "chevron.left").opacity(0)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Avatar
                        if let urlStr = user.imageURL, let url = URL(string: urlStr) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else {
                                    Circle().fill(theme.main.text.opacity(0.1))
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        } else {
                            ZStack {
                                Circle().fill(theme.main.text.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(theme.main.text.opacity(0.4))
                            }
                        }
                        
                        // Name & Bio
                        VStack(spacing: 6) {
                            Text(user.name ?? "User")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(theme.main.text)
                            
                            if let bio = user.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.system(size: 15))
                                    .foregroundColor(theme.main.text.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                        
                        // Stats Row
                        HStack(spacing: 40) {
                            statItem(title: "Followers", value: "\(socialManager.selectedUserFollowStats?.followerCount ?? 0)")
                            statItem(title: "Following", value: "\(socialManager.selectedUserFollowStats?.followingCount ?? 0)")
                            statItem(title: "Score", value: "\(user.points ?? 0)")
                        }
                        .padding(.vertical, 10)
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                if let currentUserId = authManager.currentUser?.id.uuidString, let targetUserId = user.id {
                                    Task {
                                        await socialManager.toggleFollow(currentUserId: currentUserId, targetUserId: targetUserId)
                                    }
                                }
                            }) {
                                Text(socialManager.isFollowingSelectedUser ? "Following" : "Follow")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(socialManager.isFollowingSelectedUser ? theme.main.text : .white)
                                    .frame(width: 140, height: 44)
                                    .background(socialManager.isFollowingSelectedUser ? theme.main.text.opacity(0.1) : Color(hex: "#4CAF50"))
                                    .clipShape(Capsule())
                            }
                            
                            Button(action: {
                                initChat()
                            }) {
                                HStack {
                                    if isCreatingRoom {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "message.fill")
                                        Text("Message")
                                    }
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 140, height: 44)
                                .background(Color(hex: "#2196F3"))
                                .clipShape(Capsule())
                            }
                            .disabled(isCreatingRoom)
                        }
                        
                        // Badges Area
                        if !externalUserBadges.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Trophy Cabinet")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.main.text)
                                    .padding(.horizontal, 25)
                                    .padding(.top, 10)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(externalUserBadges) { badge in
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    Circle()
                                                        .fill(
                                                            badge.rank == 1 ? Color.yellow.opacity(0.2) :
                                                            badge.rank == 2 ? Color.gray.opacity(0.2) :
                                                            Color.orange.opacity(0.2)
                                                        )
                                                        .frame(width: 60, height: 60)
                                                    Text(badge.rank == 1 ? "🥇" : (badge.rank == 2 ? "🥈" : "🥉"))
                                                        .font(.system(size: 40))
                                                        .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
                                                }
                                                Text(badge.contestTitle)
                                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                                    .foregroundColor(theme.main.text)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                                    .frame(width: 100)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 10)
                                            .background {
                                                BlurView(style: theme.main.ultraThinMaterial)
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                                    .shadow(radius: 3)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.vertical, 5)
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            
            // Hidden navigation link to chat room
            if let commonRoomId = commonRoomId, let currentUserId = authManager.currentUser?.id.uuidString {
                NavigationLink(destination: ChatRoomView(roomId: commonRoomId, recipient: user, currentUserId: currentUserId, isPresented: $navigateToChat).environmentObject(socialManager), isActive: $navigateToChat) {
                    EmptyView()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let currentUserId = authManager.currentUser?.id.uuidString, let targetUserId = user.id {
                Task {
                    await socialManager.fetchUserProfileData(userId: targetUserId, currentUserId: currentUserId)
                    await fetchUserBadges()
                }
            }
        }
    }
    
    private func fetchUserBadges() async {
        guard let userId = user.id else { return }
        do {
            let badges: [BadgeModel] = try await supabase
                .from("user_badges")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            await MainActor.run {
                self.externalUserBadges = badges
            }
        } catch {
            print("Failed fetching external user badges: \(error)")
        }
    }
    
    private func initChat() {
        guard let currentUserId = authManager.currentUser?.id.uuidString, let targetUserId = user.id else { return }
        isCreatingRoom = true
        Task {
            if let roomId = await socialManager.getOrCreateChatRoom(currentUserId: currentUserId, targetUserId: targetUserId) {
                await MainActor.run {
                    self.commonRoomId = roomId
                    self.isCreatingRoom = false
                    self.navigateToChat = true
                }
            } else {
                await MainActor.run {
                    self.isCreatingRoom = false
                }
            }
        }
    }
    
    @ViewBuilder
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.main.text)
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.main.text.opacity(0.5))
        }
    }
}
