import SwiftUI

struct UserSearchView: View {
    @EnvironmentObject var authManager: SupabaseAuthManager
    @EnvironmentObject var socialManager: SocialManager
    @EnvironmentObject var theme: AppThemeController
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var navigateToProfile: Bool = false
    @State private var selectedUser: UserModel?
    
    var body: some View {
        ZStack {
                theme.main.mainColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(theme.main.text.opacity(0.5))
                        TextField("Search by email...", text: $searchText)
                            .foregroundColor(theme.main.text)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: searchText) { newValue in
                                searchTask?.cancel()
                                searchTask = Task {
                                    try? await Task.sleep(nanoseconds: 500_000_000) // debounce
                                    if !Task.isCancelled {
                                        await socialManager.searchUsers(query: newValue)
                                    }
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                socialManager.searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(theme.main.text.opacity(0.5))
                            }
                        }
                    }
                    .padding()
                    .background(theme.main.text.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    // Results List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if searchText.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(theme.main.text.opacity(0.2))
                                    Text("Find friends to follow and chat with.")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(theme.main.text.opacity(0.4))
                                }
                                .padding(.top, 100)
                            } else if socialManager.searchResults.isEmpty {
                                Text("No users found.")
                                    .font(.system(size: 15))
                                    .foregroundColor(theme.main.text.opacity(0.5))
                                    .padding(.top, 50)
                            } else {
                                ForEach(socialManager.searchResults) { user in
                                    // Prevent showing oneself
                                    if user.id != authManager.currentUser?.id.uuidString {
                                        Button(action: {
                                            selectedUser = user
                                            navigateToProfile = true
                                        }) {
                                            searchResultRow(user: user)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
        .fullScreenCover(isPresented: $navigateToProfile) {
            if let user = selectedUser {
                PublicProfileView(user: user)
                    .environmentObject(authManager)
                    .environmentObject(socialManager)
                    .environmentObject(theme)
            }
        }
    }
    
    @ViewBuilder
    func searchResultRow(user: UserModel) -> some View {
        HStack(spacing: 16) {
            // Avatar
            if let urlStr = user.imageURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(theme.main.text.opacity(0.1))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                ZStack {
                    Circle().fill(theme.main.text.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Image(systemName: "person.fill")
                        .foregroundColor(theme.main.text.opacity(0.4))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name ?? "User")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.main.text)
                Text(user.email ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(theme.main.text.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(theme.main.text.opacity(0.3))
        }
        .padding()
        .background {
            BlurView(style: theme.main.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 16)
    }
}
