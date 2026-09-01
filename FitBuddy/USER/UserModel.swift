//
//  UserModel.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/9/25.
//

import Foundation
import SwiftUI
import Supabase
import GoogleSignIn
import Firebase

// MARK: - Supabase Profile Model
struct SupabaseProfile: Codable, Identifiable {
    let id: UUID
    var userId: String
    var username: String
    var bio: String
    var avatarUrl: String
    var backgroundUrl: String
    var createdAt: String?
    var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case username
        case bio
        case avatarUrl = "avatar_url"
        case backgroundUrl = "background_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(id: UUID, userId: String, username: String, bio: String = "", avatarUrl: String = "", backgroundUrl: String = "", createdAt: String? = nil, updatedAt: String? = nil) {
        self.id = id
        self.userId = userId
        self.username = username
        self.bio = bio
        self.avatarUrl = avatarUrl
        self.backgroundUrl = backgroundUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? ""
        self.username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio) ?? ""
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl) ?? ""
        self.backgroundUrl = try container.decodeIfPresent(String.self, forKey: .backgroundUrl) ?? ""
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}

struct ProfileInsert: Codable {
    let id: UUID
    let userId: String
    let username: String
    let bio: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case username
        case bio
    }
}

struct ProfileUpdate: Codable {
    var username: String?
    var bio: String?
    var avatarUrl: String?
    var backgroundUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case bio
        case avatarUrl = "avatar_url"
        case backgroundUrl = "background_url"
    }
}

// MARK: - Auth State
enum AuthState {
    case loading
    case unauthenticated
    case needsProfile
    case authenticated
}

// MARK: - User Controller
class UserController: ObservableObject {
    @Published var profile: SupabaseProfile?
    @Published var authState: AuthState = .loading
    @Published var authError: String?
    
    private let supabase = SupabaseManager.shared.client
    
    init(profile: SupabaseProfile? = nil) {
        self.profile = profile
        if profile != nil {
            self.authState = .authenticated
        }
    }
    
    // MARK: - Session Restore
    func restoreSession() {
        Task { @MainActor in
            do {
                let session = try await supabase.auth.session
                await fetchProfile(userId: session.user.id)
            } catch {
                self.authState = .unauthenticated
            }
        }
    }
    
    // MARK: - Google Sign-In via Supabase
    func signInWithGoogle() {
        Task { @MainActor in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                self.authError = "Could not find root view controller."
                return
            }
            
            // Read the GIDClientID directly from Info.plist
            guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
                self.authError = "GIDClientID not found in Info.plist. Please add it."
                return
            }
            
            let config = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { user, error in
                if let error = error {
                    Task { @MainActor in self.authError = error.localizedDescription }
                    return
                }
                
                guard let user = user, let idToken = user.authentication.idToken else {
                    Task { @MainActor in self.authError = "No ID token found" }
                    return
                }
                
                let accessToken = user.authentication.accessToken
                
                Task { @MainActor in
                    do {
                        // Pass the native iOS token to Supabase (no OAuth secret needed!)
                        try await self.supabase.auth.signInWithIdToken(
                            credentials: .init(
                                provider: .google,
                                idToken: idToken,
                                accessToken: accessToken
                            )
                        )
                        
                        let session = try await self.supabase.auth.session
                        await self.fetchProfile(userId: session.user.id)
                        
                    } catch {
                        self.authError = error.localizedDescription
                    }
                }
            }
        }
    }
    
    // MARK: - Handle OAuth Callback
    func handleOAuthCallback(url: URL) {
        Task { @MainActor in
            do {
                try await supabase.auth.session(from: url)
                let session = try await supabase.auth.session
                await fetchProfile(userId: session.user.id)
            } catch {
                self.authError = error.localizedDescription
                self.authState = .unauthenticated
            }
        }
    }
    
    // MARK: - Fetch Profile
    func fetchProfile(userId: UUID) async {
        do {
            let profile: SupabaseProfile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            await MainActor.run {
                self.profile = profile
                self.authState = .authenticated
            }
        } catch {
            await MainActor.run {
                self.authState = .needsProfile
            }
        }
    }
    
    // MARK: - Check User ID Availability
    // Returns: true = available, false = taken, nil = error
    func checkUserIdAvailability(userId: String) async -> Bool? {
        // Use a simple struct so we don't fail on column decode mismatches
        struct UserIdRow: Decodable { let user_id: String }
        do {
            let results: [UserIdRow] = try await supabase
                .from("profiles")
                .select("user_id")
                .eq("user_id", value: userId)
                .execute()
                .value
            return results.isEmpty   // true = no match = available
        } catch {
            await MainActor.run {
                self.authError = error.localizedDescription
            }
            return nil               // nil = network/RLS/decode error
        }
    }
    
    // MARK: - Create Profile (1 request: INSERT + returns created row)
    func createProfile(userId: String, username: String, bio: String) async -> Bool {
        do {
            let session = try await supabase.auth.session
            let insert = ProfileInsert(
                id: session.user.id,
                userId: userId,
                username: username,
                bio: bio
            )
            
            let created: SupabaseProfile = try await supabase
                .from("profiles")
                .insert(insert)
                .select()
                .single()
                .execute()
                .value
            
            await MainActor.run {
                self.profile = created
                self.authState = .authenticated
            }
            return true
        } catch {
            await MainActor.run {
                self.authError = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Update Profile (1 request: UPDATE + returns updated row)
    func updateProfile(update: ProfileUpdate) async -> Bool {
        guard let profile = profile else { return false }
        do {
            let updated: SupabaseProfile = try await supabase
                .from("profiles")
                .update(update)
                .eq("id", value: profile.id.uuidString)
                .select()
                .single()
                .execute()
                .value
            
            await MainActor.run {
                self.profile = updated   // Apply locally — no second request needed
            }
            return true
        } catch {
            await MainActor.run {
                self.authError = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Helper Image Resizer & Compressor
    private func processImageForUpload(data: Data, maxDimension: CGFloat, quality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else {
            print("[Supabase Storage] Failed to create UIImage from data (\(data.count) bytes)")
            return nil
        }
        
        let size = image.size
        var targetSize = size
        
        if size.width > maxDimension || size.height > maxDimension {
            if size.width > size.height {
                targetSize = CGSize(width: maxDimension, height: (size.height / size.width) * maxDimension)
            } else {
                targetSize = CGSize(width: (size.width / size.height) * maxDimension, height: maxDimension)
            }
        }
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resizedImage.jpegData(compressionQuality: quality)
    }
    
    // MARK: - Upload Avatar
    func uploadAvatar(imageData: Data) async -> String? {
        guard let profile = profile else {
            print("[Supabase Storage] No logged-in profile to upload avatar")
            return nil
        }
        
        guard let compressedData = processImageForUpload(data: imageData, maxDimension: 600, quality: 0.8) else {
            print("[Supabase Storage] Image processing failed for avatar")
            return nil
        }
        
        let userFolder = profile.id.uuidString.lowercased()
        let path = "\(userFolder)/avatar.jpg"
        print("[Supabase Storage] Uploading avatar (\(compressedData.count) bytes) to avatars/\(path)...")
        
        do {
            try await supabase.storage
                .from("avatars")
                .upload(path, data: compressedData, options: .init(contentType: "image/jpeg", upsert: true))
            
            let publicURL = try supabase.storage
                .from("avatars")
                .getPublicURL(path: path)
            
            // Add timestamp query parameter to bust AsyncImage / URLCache caching
            let timestamp = Int(Date().timeIntervalSince1970)
            let urlString = "\(publicURL.absoluteString)?t=\(timestamp)"
            
            let ok = await updateProfile(update: ProfileUpdate(avatarUrl: urlString))
            if ok {
                print("[Supabase Storage] Avatar successfully uploaded & profile updated: \(urlString)")
                return urlString
            } else {
                print("[Supabase Storage] Avatar uploaded to storage but failed to update profile record")
                return nil
            }
        } catch {
            print("[Supabase Storage] Upload Avatar Error: \(error.localizedDescription) - Details: \(error)")
            await MainActor.run {
                self.authError = "Storage error: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    // MARK: - Upload Background
    func uploadBackground(imageData: Data) async -> String? {
        guard let profile = profile else {
            print("[Supabase Storage] No logged-in profile to upload background")
            return nil
        }
        
        guard let compressedData = processImageForUpload(data: imageData, maxDimension: 1400, quality: 0.82) else {
            print("[Supabase Storage] Image processing failed for background")
            return nil
        }
        
        let userFolder = profile.id.uuidString.lowercased()
        let path = "\(userFolder)/background.jpg"
        print("[Supabase Storage] Uploading background (\(compressedData.count) bytes) to backgrounds/\(path)...")
        
        do {
            try await supabase.storage
                .from("backgrounds")
                .upload(path, data: compressedData, options: .init(contentType: "image/jpeg", upsert: true))
            
            let publicURL = try supabase.storage
                .from("backgrounds")
                .getPublicURL(path: path)
            
            // Add timestamp query parameter to bust AsyncImage / URLCache caching
            let timestamp = Int(Date().timeIntervalSince1970)
            let urlString = "\(publicURL.absoluteString)?t=\(timestamp)"
            
            let ok = await updateProfile(update: ProfileUpdate(backgroundUrl: urlString))
            if ok {
                print("[Supabase Storage] Background successfully uploaded & profile updated: \(urlString)")
                return urlString
            } else {
                print("[Supabase Storage] Background uploaded to storage but failed to update profile record")
                return nil
            }
        } catch {
            print("[Supabase Storage] Upload Background Error: \(error.localizedDescription) - Details: \(error)")
            await MainActor.run {
                self.authError = "Storage error: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        Task { @MainActor in
            do {
                try await supabase.auth.signOut()
                self.profile = nil
                self.authState = .unauthenticated
            } catch {
                self.authError = error.localizedDescription
            }
        }
    }
}

// MARK: - Legacy compatibility
struct UserModel: Codable, Identifiable {
    let id: String?
    let name: String?
    let email: String?
    let imageURL: String?
}
