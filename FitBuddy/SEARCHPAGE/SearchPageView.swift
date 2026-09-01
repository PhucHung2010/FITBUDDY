//
//  SearchPageView.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//

import SwiftUI
import Supabase

struct SearchPageView: View {
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var userController: UserController
    
    @State private var searchText: String = ""
    @State private var searchResults: [SupabaseProfile] = []
    @State private var isSearching: Bool = false
    @State private var selectedProfile: SupabaseProfile? = nil
    @State private var searchTask: Task<Void, Never>? = nil
    @State private var searchCache: [String: [SupabaseProfile]] = [:]
    @State private var lastExecutedQuery: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        ZStack {
            if let profile = selectedProfile {
                SearchedUserProfileView(
                    profile: profile,
                    onBack: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                            selectedProfile = nil
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            } else {
                VStack(spacing: 0) {

                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(theme.main.text.opacity(0.45))
                            .font(.system(size: 16, weight: .semibold))
                        
                        TextField("Search by username or user ID...", text: $searchText)
                            .focused($isSearchFieldFocused)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.search)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(theme.main.text)
                            .onChange(of: searchText) { newValue in
                                debounceSearch(query: newValue)
                            }
                            .onSubmit(of: .text) {
                                triggerImmediateSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                                searchTask?.cancel()
                                isSearching = false
                                lastExecutedQuery = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(theme.main.text.opacity(0.4))
                                    .font(.system(size: 14))
                            }
                        } else {
                            NeumorphicIndicatorDots(dotSize: 4, spacing: 3)
                        }
                        
                        if isSearching {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .neumorphicInset(cornerRadius: 23)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    // Results
                    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.isEmpty {
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 44))
                                .foregroundColor(theme.main.text.opacity(0.25))
                            Text("Search for friends by username or user ID")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.45))
                            Spacer()
                        }
                    } else if trimmed.count < 2 {
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "character.cursor.ibeam")
                                .font(.system(size: 40))
                                .foregroundColor(theme.main.text.opacity(0.3))
                            Text("Type at least 2 characters to search")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.45))
                            Spacer()
                        }
                    } else if searchResults.isEmpty && !isSearching {
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "person.slash.fill")
                                .font(.system(size: 44))
                                .foregroundColor(theme.main.text.opacity(0.3))
                            Text("No users found")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.main.text.opacity(0.5))
                            Spacer()
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(searchResults) { profile in
                                    SearchResultCard(profile: profile)
                                        .onTapGesture {
                                            isSearchFieldFocused = false
                                            withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                                                selectedProfile = profile
                                            }
                                        }
                                }
                            }
                            .padding(.top, 14)
                            .padding(.horizontal, 16)
                            
                            Spacer().frame(height: 100)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                }
            }
        }
        .background(AppBackground().ignoresSafeArea())
        .animation(.spring(response: 0.4, dampingFraction: 1), value: selectedProfile?.id)
    }
    
    private func triggerImmediateSearch() {
        searchTask?.cancel()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return }
        
        searchTask = Task {
            await performSearch(query: trimmed)
        }
    }
    
    private func debounceSearch(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            if trimmed.isEmpty {
                searchResults = []
            }
            isSearching = false
            return
        }
        
        let cacheKey = trimmed.lowercased()
        // Instant response from in-memory cache without debounce delay or network request
        if let cached = searchCache[cacheKey] {
            self.searchResults = cached
            self.isSearching = false
            self.lastExecutedQuery = cacheKey
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 450_000_000) // Original 450ms debounce
            guard !Task.isCancelled else { return }
            await performSearch(query: trimmed)
        }
    }
    
    private func performSearch(query: String) async {
        // Sanitize characters that conflict with PostgREST filter delimiters
        let sanitized = query
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\\", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            
        guard sanitized.count >= 2 else {
            await MainActor.run {
                self.isSearching = false
            }
            return
        }
        
        let cacheKey = sanitized.lowercased()
        if cacheKey == lastExecutedQuery, !searchResults.isEmpty {
            await MainActor.run { self.isSearching = false }
            return
        }
        
        // In-memory cache hit
        if let cached = searchCache[cacheKey] {
            await MainActor.run {
                self.searchResults = cached
                self.isSearching = false
                self.lastExecutedQuery = cacheKey
            }
            return
        }
        
        await MainActor.run { isSearching = true }
        
        do {
            struct SearchRPCParams: Codable {
                let searchQuery: String
                let currentUserId: String?
                let resultLimit: Int
                
                enum CodingKeys: String, CodingKey {
                    case searchQuery = "search_query"
                    case currentUserId = "current_user_id"
                    case resultLimit = "result_limit"
                }
            }
            
            let currentIdStr = userController.profile?.id.uuidString
            let params = SearchRPCParams(searchQuery: sanitized, currentUserId: currentIdStr, resultLimit: 20)
            
            let rpcResults: [SupabaseProfile]? = try? await SupabaseManager.shared.client
                .rpc("search_profiles", params: params)
                .execute()
                .value
            
            let results: [SupabaseProfile]
            if let rpcResults = rpcResults {
                results = rpcResults
            } else {
                // Direct fallback
                var request = SupabaseManager.shared.client
                    .from("profiles")
                    .select("id, user_id, username, bio, avatar_url, background_url")
                    .or("user_id.ilike.%\(sanitized)%,username.ilike.%\(sanitized)%")
                
                if let currentUserId = userController.profile?.id {
                    request = request.neq("id", value: currentUserId.uuidString)
                }
                
                results = try await request.limit(20).execute().value
            }
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self.searchCache[cacheKey] = results
                self.searchResults = results
                self.lastExecutedQuery = cacheKey
                self.isSearching = false
            }
        } catch {
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.searchResults = []
                self.isSearching = false
            }
        }
    }
}


// MARK: - Search Result Card
struct SearchResultCard: View {
    let profile: SupabaseProfile
    @EnvironmentObject var theme: AppThemeController
    
    var body: some View {
        HStack(spacing: 14) {
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
                .frame(width: 48, height: 48)
                .neumorphicCircle()
            } else {
                defaultAvatar
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(profile.username)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
                
                Text("@\(profile.userId)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.25))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.main.text.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .neumorphicCard(cornerRadius: 20)
    }
    
    private var defaultAvatar: some View {
        Circle()
            .fill(theme.accentGradient)
            .frame(width: 48, height: 48)
            .overlay {
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
            .neumorphicCircle()
    }
}


struct SearchPageView_Previews: PreviewProvider {
    static var previews: some View {
        SearchPageView()
            .environmentObject(AppThemeController())
            .environmentObject(UserController())
            .environmentObject(TabViewController())
    }
}
