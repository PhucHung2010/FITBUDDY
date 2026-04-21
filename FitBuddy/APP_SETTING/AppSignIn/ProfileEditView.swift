//
//  ProfileEditView.swift
//  FitBuddy
//
//  Created for FitBuddy.
//

import SwiftUI
import Foundation
import PhotosUI

struct ProfileEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: SupabaseAuthManager
    @EnvironmentObject var theme: AppThemeController
    
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var avatarURL: String = ""
    
    // Photo Picker States
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var localAvatarImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(theme.main.text.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Text("Edit Profile")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text)
                        
                        Spacer()
                        
                        Button(action: saveProfile) {
                            Text("Save")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Avatar Image Picker
                    VStack {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                            if let localImage = localAvatarImage {
                                Image(uiImage: localImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(theme.main.text.opacity(0.2), lineWidth: 2))
                            } else if !avatarURL.isEmpty, let url = URL(string: avatarURL) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                        .resizable()
                                        .scaledToFill()
                                    } else {
                                        ProgressView()
                                    }
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(theme.main.text.opacity(0.2), lineWidth: 2))
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(theme.main.text.opacity(0.1))
                                        .frame(width: 120, height: 120)
                                    Image(systemName: "camera.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(theme.main.text.opacity(0.5))
                                        .frame(width: 40, height: 40)
                                }
                            }
                        }
                        .onChange(of: selectedPhotoItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    await MainActor.run {
                                        localAvatarImage = image
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                    // Form fields
                    VStack(spacing: 15) {
                        ProfileField(title: "Full Name", text: $name, theme: theme)
                        ProfileField(title: "Username", text: $username, theme: theme)
                        
                        VStack(alignment: .leading) {
                            Text("Bio")
                                .foregroundColor(theme.main.text.opacity(0.8))
                                .font(.system(size: 14))
                            
                            TextEditor(text: $bio)
                                .frame(height: 100)
                                .scrollContentBackground(.hidden)
                                .padding(5)
                                .background { BlurView(style: theme.main.ultraThinMaterial) }
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .foregroundColor(theme.main.text)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let error = authManager.errorMessage {
                        Text(error)
                            .foregroundColor(error.contains("success") ? .green : .red)
                            .font(.caption)
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            if let profile = authManager.currentUserProfile {
                name = profile.name ?? ""
                username = profile.username ?? ""
                bio = profile.bio ?? ""
                avatarURL = profile.imageURL ?? ""
            } else if let user = authManager.currentUser {
                name = user.userMetadata["full_name"]?.value as? String ?? ""
                avatarURL = user.userMetadata["avatar_url"]?.value as? String ?? ""
            }
        }
    }
    
    private func saveProfile() {
        var newProfile = authManager.currentUserProfile ?? UserModel(id: authManager.currentUser?.id.uuidString, name: nil, email: nil, imageURL: nil, bio: nil, username: nil)
        newProfile.name = name
        newProfile.username = username
        newProfile.bio = bio
        // avatarURL will be updated in authManager if localAvatarImage is present.
        newProfile.imageURL = avatarURL
        
        Task {
            if let image = localAvatarImage {
                if let newUrl = await authManager.uploadAvatar(image: image) {
                    newProfile.imageURL = newUrl
                }
            }
            await authManager.updateProfile(updatedProfile: newProfile)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProfileField: View {
    var title: String
    @Binding var text: String
    var theme: AppThemeController
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(theme.main.text.opacity(0.8))
                .font(.system(size: 14))
            
            TextField(title, text: $text)
                .padding()
                .background { BlurView(style: theme.main.ultraThinMaterial) }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(theme.main.text)
        }
    }
}
