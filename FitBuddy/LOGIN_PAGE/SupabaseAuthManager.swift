//
//  SupabaseAuthManager.swift
//  FitBuddy
//
//  Manages Supabase Authentication: Sign In with Google, Log Out
//

import Foundation
import SwiftUI
import Supabase
import GoogleSignIn

// MARK: - Supabase Client (Singleton)
let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://qovhvfmikpuqstsqqakj.supabase.co")!,
    supabaseKey: "sb_publishable_CdLQFBgZ3KI-iFq4pmmErg_t3Fd7-9k"
)

// MARK: - Auth Manager
class SupabaseAuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var currentUserProfile: UserModel? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    init() {
        Task {
            await checkSession()
        }
    }

    // MARK: - Check Existing Session
    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            await MainActor.run {
                self.currentUser = session.user
                self.isAuthenticated = true
            }
            await fetchProfile(userId: session.user.id)
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
                self.currentUserProfile = nil
            }
        }
    }

    // MARK: - Sign In with Google
    func signInWithGoogle() {
        Task {
            await MainActor.run { self.isLoading = true; self.errorMessage = nil }
            
            do {
                guard let rootViewController = await MainActor.run(body: {
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap { $0.windows }
                        .first { $0.isKeyWindow }?.rootViewController
                }) else {
                    await MainActor.run {
                        self.errorMessage = "Cannot find root view controller"
                        self.isLoading = false
                    }
                    return
                }
                
                let clientID = "841610832624-prbkvi4b9h2t2cn8q58v5eevb8mqcr9n.apps.googleusercontent.com"
                let config = GIDConfiguration(clientID: clientID)
                
                // Google Sign-In SDK 6.x returns GIDGoogleUser
                let user: GIDGoogleUser = try await withCheckedThrowingContinuation { continuation in
                    DispatchQueue.main.async {
                        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { user, error in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let user = user {
                                continuation.resume(returning: user)
                            } else {
                                continuation.resume(throwing: NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user returned"]))
                            }
                        }
                    }
                }
                
                guard let idToken = user.authentication.idToken else {
                    await MainActor.run {
                        self.errorMessage = "Missing Google ID token"
                        self.isLoading = false
                    }
                    return
                }
                
                let session = try await supabase.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .google,
                        idToken: idToken,
                        accessToken: user.authentication.accessToken
                    )
                )
                
                await MainActor.run {
                    self.currentUser = session.user
                    self.isAuthenticated = true
                    self.isLoading = false
                }
                
                await fetchProfile(userId: session.user.id)
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Log Out
    func logOut() {
        Task {
            do {
                try await supabase.auth.signOut()
                GIDSignIn.sharedInstance.signOut()
                await MainActor.run {
                    self.currentUser = nil
                    self.isAuthenticated = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    // MARK: - API Profile Methods
    
    func fetchProfile(userId: UUID) async {
        do {
            let profile: UserModel = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
                
            await MainActor.run {
                self.currentUserProfile = profile
            }
        } catch {
            // Profile might not exist yet, or error fetching
            print("Failed to fetch profile: \(error)")
        }
    }
    
    func updateProfile(updatedProfile: UserModel) async {
        guard let userId = currentUser?.id else { return }
        
        // Supabase requires dict representation to update only specific columns
        var updateData: [String: String] = ["id": userId.uuidString]
        if let name = updatedProfile.name { updateData["name"] = name }
        if let username = updatedProfile.username { updateData["username"] = username }
        if let bio = updatedProfile.bio { updateData["bio"] = bio }
        if let imageURL = updatedProfile.imageURL { updateData["avatar_url"] = imageURL }
        
        do {
            try await supabase
                .from("profiles")
                .upsert(updateData)
                .execute()
                
            await fetchProfile(userId: userId)
            
            await MainActor.run {
                self.errorMessage = "Profile saved successfully."
                // temporary message clearing
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if self.errorMessage == "Profile saved successfully." {
                        self.errorMessage = nil
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - API Storage Methods
    
    func uploadAvatar(image: UIImage) async -> String? {
        guard let userId = currentUser?.id else {
            print("❌ Upload failed: No current user ID")
            return nil
        }
        
        // Compress UIImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            await MainActor.run { self.errorMessage = "Failed to convert image to data." }
            return nil
        }
        
        let fileName = "\(userId.uuidString).jpg"
        
        print("📤 Uploading avatar: \(fileName), size: \(imageData.count) bytes")
        
        do {
            // Upload to Supabase Storage in 'avatars' bucket
            let options = FileOptions(
                cacheControl: "0",
                contentType: "image/jpeg",
                upsert: true
            )
            
            let result = try await supabase.storage
                .from("avatars")
                .upload(fileName, data: imageData, options: options)
            
            print("✅ Upload success: \(result.path)")
            
            // Construct the public URL with cache-busting timestamp
            let timestamp = Int(Date().timeIntervalSince1970)
            let publicURL = "https://qovhvfmikpuqstsqqakj.supabase.co/storage/v1/object/public/avatars/\(fileName)?t=\(timestamp)"
            
            return publicURL
        } catch {
            print("❌ Full upload error: \(error)")
            print("❌ Error description: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "Image upload failed: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    // MARK: - Contest Methods
    
    @Published var contests: [ContestModel] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    
    func fetchContests() async {
        do {
            var fetched: [ContestModel] = try await supabase
                .from("contests")
                .select()
                .execute()
                .value
            
            // For each contest, get participant count and check if current user joined
            for i in fetched.indices {
                let countResult: [ContestParticipant] = try await supabase
                    .from("contest_participants")
                    .select()
                    .eq("contest_id", value: fetched[i].id)
                    .execute()
                    .value
                fetched[i].participantCount = countResult.count
                
                if let userId = currentUser?.id {
                    fetched[i].isJoined = countResult.contains { $0.userId == userId.uuidString }
                }
            }
            
            await MainActor.run {
                self.contests = fetched
            }
        } catch {
            print("❌ Failed to fetch contests: \(error)")
        }
    }
    
    func joinContest(contestId: String) async {
        guard let userId = currentUser?.id else { return }
        
        let data: [String: String] = [
            "contest_id": contestId,
            "user_id": userId.uuidString
        ]
        
        do {
            try await supabase
                .from("contest_participants")
                .upsert(data, onConflict: "contest_id,user_id", ignoreDuplicates: true)
                .execute()
            
            await fetchContests()
        } catch {
            print("⚠️ Join contest note: \(error)")
            // Still refresh in case user is already joined
            await fetchContests()
        }
    }
    
    func submitContestResult(contestId: String, accuracy: Double, timeSeconds: Double) async {
        guard let userId = currentUser?.id else { return }
        
        let updateData: [String: AnyEncodable] = [
            "accuracy": AnyEncodable(accuracy),
            "time_seconds": AnyEncodable(timeSeconds),
            "completed": AnyEncodable(true),
            "completed_at": AnyEncodable(ISO8601DateFormatter().string(from: Date()))
        ]
        
        do {
            try await supabase
                .from("contest_participants")
                .update(updateData)
                .eq("contest_id", value: contestId)
                .eq("user_id", value: userId.uuidString)
                .execute()
            
            print("✅ Contest result submitted: accuracy=\(accuracy), time=\(timeSeconds)")
        } catch {
            print("❌ Failed to submit contest result: \(error)")
        }
    }
    
    func fetchLeaderboard(contestId: String) async {
        do {
            let entries: [LeaderboardEntry] = try await supabase
                .from("contest_participants")
                .select("*, profiles(name, username, avatar_url)")
                .eq("contest_id", value: contestId)
                .eq("completed", value: true)
                .order("accuracy", ascending: false)
                .order("time_seconds", ascending: true)
                .execute()
                .value
            
            await MainActor.run {
                self.leaderboard = entries
            }
        } catch {
            print("❌ Failed to fetch leaderboard: \(error)")
        }
    }
    
    func awardContestPoints(contestId: String, pointsReward: Int) async {
        guard let userId = currentUser?.id else { return }
        
        // Get current points
        let currentPoints = currentUserProfile?.points ?? 0
        let newPoints = currentPoints + pointsReward
        
        let updateData: [String: AnyEncodable] = [
            "id": AnyEncodable(userId.uuidString),
            "points": AnyEncodable(newPoints)
        ]
        
        do {
            try await supabase
                .from("profiles")
                .upsert(updateData)
                .execute()
            
            await fetchProfile(userId: userId)
            print("✅ Awarded \(pointsReward) points. Total: \(newPoints)")
        } catch {
            print("❌ Failed to award points: \(error)")
        }
    }
}

// MARK: - AnyEncodable Helper (for mixed-type dictionaries)
struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    
    init<T: Encodable>(_ wrapped: T) {
        self._encode = { encoder in
            try wrapped.encode(to: encoder)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
