import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var authManager: SupabaseAuthManager
    @EnvironmentObject var socialManager: SocialManager
    @EnvironmentObject var theme: AppThemeController
    
    @State private var navigateToChat: Bool = false
    @State private var selectedRoomId: String = ""
    @State private var selectedRecipient: UserModel? = nil
    
    var body: some View {
        ZStack {
                theme.main.mainColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Messages")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    if socialManager.myChatRooms.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 50))
                                .foregroundColor(theme.main.text.opacity(0.1))
                            Text("No chats yet")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(theme.main.text.opacity(0.4))
                            Text("Find a user's profile to start chatting.")
                                .font(.system(size: 14))
                                .foregroundColor(theme.main.text.opacity(0.3))
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(socialManager.myChatRooms) { roomData in
                                    if let recipient = roomData.recipient {
                                        Button(action: {
                                            selectedRoomId = roomData.room.id
                                            selectedRecipient = recipient
                                            navigateToChat = true
                                        }) {
                                            chatRow(recipient: recipient)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 100) // Space for tab bar
                        }
                    }
                }
            }
            .onAppear {
                if let currentUserId = authManager.currentUser?.id.uuidString {
                    Task {
                        await socialManager.loadMyChatRooms(currentUserId: currentUserId)
                    }
                }
            }
        .fullScreenCover(isPresented: $navigateToChat) {
            if let recipient = selectedRecipient, let currentUserId = authManager.currentUser?.id.uuidString {
                ChatRoomView(roomId: selectedRoomId, recipient: recipient, currentUserId: currentUserId, isPresented: $navigateToChat)
                    .environmentObject(socialManager)
                    .environmentObject(theme)
            }
        }
    }
    
    @ViewBuilder
    func chatRow(recipient: UserModel) -> some View {
        HStack(spacing: 16) {
            if let urlStr = recipient.imageURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Circle().fill(theme.main.text.opacity(0.1))
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
            } else {
                Circle().fill(theme.main.text.opacity(0.1))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(theme.main.text.opacity(0.4))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipient.name ?? "User")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
                Text("Tap to chat...")
                    .font(.system(size: 14))
                    .foregroundColor(theme.main.text.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(theme.main.text.opacity(0.2))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.001)) // make tappable
    }
}
