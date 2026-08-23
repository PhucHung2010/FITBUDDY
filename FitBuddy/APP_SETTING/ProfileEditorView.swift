//
//  ProfileEditorView.swift
//  FitBuddy
//
//  Professional Neumorphic Profile & Bio Editor
//  Vector Kit 4786587.jpg Design System
//

import SwiftUI
import PhotosUI

struct ProfileEditorView: View {
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var theme: AppThemeController

    @State private var bio: String = ""
    @State private var isSaving = false
    @State private var saveMessage: String? = nil
    @State private var errorMessage: String? = nil

    @State private var avatarItem: PhotosPickerItem? = nil
    @State private var backgroundItem: PhotosPickerItem? = nil
    @State private var isUploadingAvatar = false
    @State private var isUploadingBackground = false

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Hero Profile Card (Cover + Avatar)
            heroHeader
                .padding(.horizontal, 16)

            // MARK: - Identity & Bio Studio Card
            profileStudioCard
                .padding(.horizontal, 16)

            // MARK: - Action / Logout Bar
            logoutButton
                .padding(.horizontal, 16)
        }
        .onAppear {
            bio = userController.profile?.bio ?? ""
        }
        .onChange(of: userController.profile?.bio) { newBio in
            if let newBio { bio = newBio }
        }
        .onChange(of: userController.authError) { err in
            if let err, !err.isEmpty {
                withAnimation { errorMessage = err }
            }
        }
    }

    // MARK: - Hero Header
    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            // Cover Image / Dynamic Accent Gradient
            coverView
                .frame(height: 175)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .neumorphicCard(cornerRadius: 26)

            // Gradient Scrim for Contrast
            LinearGradient(
                colors: [.clear, .black.opacity(0.42)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .frame(height: 175)
            .frame(maxWidth: .infinity)

            // Change Cover Photo Button (Top Right)
            VStack {
                HStack {
                    Spacer()
                    PhotosPicker(selection: $backgroundItem, matching: .images) {
                        HStack(spacing: 6) {
                            if isUploadingBackground {
                                ProgressView()
                                    .scaleEffect(0.75)
                                    .tint(.white)
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            Text(isUploadingBackground ? "Uploading..." : "Cover")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.35))
                                .background(.ultraThinMaterial, in: Capsule())
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
                    }
                    .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.92))
                    .padding(12)
                }
                Spacer()
            }

            // Avatar + User Identity Bar (Bottom)
            HStack(alignment: .bottom, spacing: 14) {
                avatarView

                VStack(alignment: .leading, spacing: 2) {
                    Text(userController.profile?.username ?? "FitBuddy User")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.4), radius: 3, y: 1)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text("@\(userController.profile?.userId ?? "user")")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(NeumorphicColors.dotBlue)
                    }
                    .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .onChange(of: backgroundItem) { item in uploadBackground(item: item) }
    }

    // MARK: - Cover View
    private var coverView: some View {
        Group {
            if let url = userController.profile?.backgroundUrl, !url.isEmpty, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .empty:
                        ZStack {
                            theme.accentGradient
                            ProgressView().tint(.white)
                        }
                    default:
                        theme.accentGradient
                    }
                }
            } else {
                theme.accentGradient
            }
        }
    }

    // MARK: - Avatar View
    private var avatarView: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let url = userController.profile?.avatarUrl, !url.isEmpty, let imageURL = URL(string: url) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .empty:
                            avatarPlaceholder
                                .overlay(ProgressView().tint(.white))
                        default:
                            avatarPlaceholder
                        }
                    }
                } else {
                    avatarPlaceholder
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2.5)
            )
            .neumorphicCircle(shadowRadius: 8, shadowDistance: 4)

            // Edit Avatar Camera Badge
            PhotosPicker(selection: $avatarItem, matching: .images) {
                ZStack {
                    Circle()
                        .fill(theme.appTheme == .light ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface)
                        .frame(width: 28, height: 28)
                        .neumorphicCircle(shadowRadius: 4, shadowDistance: 2)
                    
                    if isUploadingAvatar {
                        ProgressView()
                            .scaleEffect(0.65)
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(theme.main.text)
                    }
                }
            }
            .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.88))
            .offset(x: 2, y: 2)
        }
        .onChange(of: avatarItem) { item in uploadAvatar(item: item) }
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(theme.accentGradient)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
    }

    // MARK: - Profile Studio & Bio Card
    private var profileStudioCard: some View {
        VStack(spacing: 14) {
            // Identity Readouts Row
            HStack(spacing: 12) {
                // User ID Pill
                HStack(spacing: 8) {
                    Image(systemName: "at")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(theme.accentColor)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("User ID")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.4))
                            .textCase(.uppercase)
                        Text(userController.profile?.userId ?? "–")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text)
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundColor(theme.main.text.opacity(0.3))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .neumorphicInset(cornerRadius: 16)

                // Display Name Pill
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(theme.accentColor)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Name")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.4))
                            .textCase(.uppercase)
                        Text(userController.profile?.username ?? "–")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .neumorphicInset(cornerRadius: 16)
            }

            // Bio Editor Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("About / Bio", systemImage: "quote.opening")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text)
                    
                    Spacer()
                    
                    Text("\(bio.count)/200")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(bio.count > 180 ? .orange : theme.main.text.opacity(0.4))
                }
                .padding(.horizontal, 4)

                // Debossed TextEditor Sunken Well
                ZStack(alignment: .topLeading) {
                    if bio.isEmpty {
                        Text("Share your fitness journey, goals, or favorite workouts...")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.35))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                    }

                    TextEditor(text: $bio)
                        .scrollContentBackground(.hidden)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(theme.main.text)
                        .frame(height: 75)
                        .padding(8)
                        .onChange(of: bio) { v in
                            if v.count > 200 { bio = String(v.prefix(200)) }
                        }
                }
                .neumorphicInset(cornerRadius: 18)
            }

            // Save Bio Button with Dynamic Accent Gradient
            Button(action: saveBio) {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .scaleEffect(0.85)
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15, weight: .bold))
                        Text("Save Bio")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(theme.accentGradient)
                        .shadow(color: theme.accentColor.opacity(0.35), radius: 5, y: 2)
                )
            }
            .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
            .disabled(isSaving)

            // Status Messages (Success / Error Toast)
            if let msg = saveMessage {
                HStack(spacing: 6) {
                    Image(systemName: msg.hasPrefix("✓") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(msg)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundColor(msg.hasPrefix("✓") ? NeumorphicColors.dotGreen : .red)
                .padding(.vertical, 4)
                .transition(.opacity.combined(with: .scale))
            }

            if let err = errorMessage {
                Text(err)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .transition(.opacity)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .neumorphicCard(cornerRadius: 26)
    }

    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: { userController.signOut() }) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14, weight: .bold))
                Text("Log Out")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .neumorphicPill()
        }
        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
    }

    // MARK: - Actions
    private func saveBio() {
        isSaving = true
        saveMessage = nil
        errorMessage = nil
        Task {
            let ok = await userController.updateProfile(update: ProfileUpdate(bio: bio))
            await MainActor.run {
                isSaving = false
                withAnimation { saveMessage = ok ? "✓ Bio updated successfully" : "✗ Failed to update bio" }
                if ok {
                    Task {
                        try? await Task.sleep(nanoseconds: 2_500_000_000)
                        await MainActor.run { saveMessage = nil }
                    }
                }
            }
        }
    }

    private func uploadAvatar(item: PhotosPickerItem?) {
        guard let item else { return }
        isUploadingAvatar = true
        errorMessage = nil
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let result = await userController.uploadAvatar(imageData: data)
                await MainActor.run {
                    isUploadingAvatar = false
                    if result == nil {
                        errorMessage = userController.authError ?? "Failed to upload avatar"
                    }
                }
            } else {
                await MainActor.run {
                    isUploadingAvatar = false
                    errorMessage = "Could not load selected image"
                }
            }
        }
    }

    private func uploadBackground(item: PhotosPickerItem?) {
        guard let item else { return }
        isUploadingBackground = true
        errorMessage = nil
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let result = await userController.uploadBackground(imageData: data)
                await MainActor.run {
                    isUploadingBackground = false
                    if result == nil {
                        errorMessage = userController.authError ?? "Failed to upload cover"
                    }
                }
            } else {
                await MainActor.run {
                    isUploadingBackground = false
                    errorMessage = "Could not load selected image"
                }
            }
        }
    }
}

struct ProfileEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground()
            ProfileEditorView()
        }
        .environmentObject(UserController())
        .environmentObject(AppThemeController())
    }
}

