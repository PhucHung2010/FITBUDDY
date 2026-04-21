import SwiftUI

struct ChatRoomView: View {
    let roomId: String
    let recipient: UserModel
    let currentUserId: String
    
    @Binding var isPresented: Bool
    @EnvironmentObject var socialManager: SocialManager
    @EnvironmentObject var theme: AppThemeController
    @Environment(\.presentationMode) var presentationMode
    
    @State private var draftMessage: String = ""
    @Namespace var bottomID
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Button(action: {
                    socialManager.stopListening()
                    isPresented = false
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.main.text)
                }
                
                if let urlStr = recipient.imageURL, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Circle().fill(theme.main.text.opacity(0.1))
                        }
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                } else {
                    Circle().fill(theme.main.text.opacity(0.2))
                        .frame(width: 36, height: 36)
                }
                
                Text(recipient.name ?? "Chat")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(theme.main.mainColor)
            .shadow(color: .black.opacity(0.05), radius: 5, y: 5)
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(socialManager.currentRoomMessages) { msg in
                            MessageBubble(message: msg, isMe: msg.senderId == currentUserId)
                                .id(msg.id)
                        }
                        
                        Color.clear
                            .frame(height: 1)
                            .id(bottomID)
                    }
                    .padding()
                }
                .onChange(of: socialManager.currentRoomMessages) { _ in
                    withAnimation {
                        proxy.scrollTo(bottomID, anchor: .bottom)
                    }
                }
                .onAppear {
                    proxy.scrollTo(bottomID, anchor: .bottom)
                }
            }
            .background(theme.main.text.opacity(0.02))
            
            // Input Bar
            HStack(spacing: 12) {
                TextField("Message...", text: $draftMessage)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(theme.main.text.opacity(0.05))
                    .clipShape(Capsule())
                
                Button(action: {
                    let text = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    draftMessage = ""
                    Task {
                        await socialManager.sendMessage(roomId: roomId, senderId: currentUserId, content: text)
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(draftMessage.isEmpty ? theme.main.text.opacity(0.3) : Color(hex: "#2196F3"))
                }
                .disabled(draftMessage.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(theme.main.mainColor)
        }
        .navigationBarHidden(true)
        .onAppear {
            socialManager.subscribeToMessages(roomId: roomId)
        }
        .onDisappear {
            socialManager.stopListening()
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    let isMe: Bool
    @EnvironmentObject var theme: AppThemeController
    
    var body: some View {
        HStack {
            if isMe { Spacer() }
            
            Text(message.content)
                .font(.system(size: 15))
                .foregroundColor(isMe ? .white : theme.main.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isMe ? Color(hex: "#2196F3") : theme.main.text.opacity(0.1))
                .clipShape(ChatBubbleShape(isMe: isMe))
            
            if !isMe { Spacer() }
        }
    }
}

// SwiftUI Chat Bubble Shape Customization
struct ChatBubbleShape: Shape {
    let isMe: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [
                                    .topLeft,
                                    .topRight,
                                    isMe ? .bottomLeft : .bottomRight
                                ],
                                cornerRadii: CGSize(width: 16, height: 16))
        return Path(path.cgPath)
    }
}
