//
//  ProfileSetupView.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//

import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var theme: AppThemeController
    
    @State private var userId: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    
    @State private var isCheckingId: Bool = false
    @State private var isIdAvailable: Bool? = nil   // nil=unchecked, true=available, false=taken
    @State private var checkError: Bool = false      // true if the availability check itself failed
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    @FocusState private var focusedField: Field?
    
    enum Field { case userId, username, bio }
    
    private var isFormValid: Bool {
        !userId.isEmpty && !username.isEmpty && userId.count >= 3 && isIdAvailable == true
    }
    
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Sign out / back button
                    HStack {
                        Button(action: { userController.signOut() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Sign Out")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(NeumorphicColors.lightTextPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .neumorphicPill()
                        }
                        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.94))
                        
                        Spacer()
                        
                        NeumorphicIndicatorDots(dotSize: 5, spacing: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    // Header Hub
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(NeumorphicColors.lightSurface)
                                .frame(width: 90, height: 90)
                                .neumorphicCircle(shadowRadius: 10, shadowDistance: 6)
                            
                            Circle()
                                .fill(theme.accentGradient)
                                .frame(width: 60, height: 60)
                                .shadow(color: Color.black.opacity(0.18), radius: 6, y: 3)
                            
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Set Up Your Profile")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(NeumorphicColors.lightTextHeadings)
                        
                        Text("Choose a unique ID so your friends can find you")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(NeumorphicColors.lightTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Form card
                    VStack(spacing: 20) {
                        
                        // ---- User ID ----
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "at")
                                    .font(.system(size: 11, weight: .bold))
                                Text("User ID")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(NeumorphicColors.lightTextPrimary)
                            
                            HStack(spacing: 8) {
                                Text("@")
                                    .foregroundColor(theme.accentColor)
                                    .font(.system(size: 17, weight: .bold))
                                
                                TextField("fitbuddy123", text: $userId)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(NeumorphicColors.lightTextHeadings)
                                    .focused($focusedField, equals: .userId)
                                    .onChange(of: userId) { newValue in
                                        let clean = newValue.lowercased()
                                            .filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "." }
                                        if clean != newValue { userId = clean }
                                        isIdAvailable = nil
                                    }
                                
                                Spacer()
                                
                                if isCheckingId {
                                    ProgressView()
                                        .tint(theme.accentColor)
                                        .scaleEffect(0.8)
                                } else if let available = isIdAvailable {
                                    Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(available ? NeumorphicColors.dotGreen : NeumorphicColors.dotRed)
                                        .font(.system(size: 18))
                                        .transition(.scale.combined(with: .opacity))
                                } else if userId.count >= 3 {
                                    Button(action: checkAvailability) {
                                        Text("Check")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Capsule().fill(theme.accentGradient))
                                    }
                                    .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.92))
                                }
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .neumorphicInset(cornerRadius: 16)
                            .animation(.easeInOut(duration: 0.2), value: isIdAvailable)
                            
                            Group {
                                if checkError {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("Could not verify. Tap Check again.", systemImage: "wifi.exclamationmark")
                                            .foregroundColor(NeumorphicColors.dotYellow)
                                        if let err = userController.authError {
                                            Text(err)
                                                .font(.system(size: 11, weight: .regular))
                                                .foregroundColor(NeumorphicColors.lightTextSecondary)
                                                .lineLimit(3)
                                        }
                                    }
                                } else if isIdAvailable == false {
                                    Label("This user ID is already taken", systemImage: "exclamationmark.circle.fill")
                                        .foregroundColor(NeumorphicColors.dotRed)
                                } else if isIdAvailable == true {
                                    Label("User ID is available!", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(NeumorphicColors.dotGreen)
                                } else if userId.count > 0 && userId.count < 3 {
                                    Label("At least 3 characters required", systemImage: "info.circle")
                                        .foregroundColor(NeumorphicColors.dotYellow)
                                }
                            }
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .padding(.leading, 4)
                            .animation(.easeInOut(duration: 0.2), value: isIdAvailable)
                            .animation(.easeInOut(duration: 0.2), value: checkError)
                        }
                        
                        divider
                        
                        // ---- Display Name ----
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Display Name", systemImage: "person.text.rectangle")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(NeumorphicColors.lightTextPrimary)
                            
                            TextField("Your Name", text: $username)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(NeumorphicColors.lightTextHeadings)
                                .focused($focusedField, equals: .username)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .neumorphicInset(cornerRadius: 16)
                        }
                        
                        divider
                        
                        // ---- Bio ----
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "text.quote")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(NeumorphicColors.lightTextPrimary)
                                Text("Bio")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(NeumorphicColors.lightTextPrimary)
                                Text("(optional)")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(NeumorphicColors.lightTextSecondary)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if bio.isEmpty {
                                    Text("Tell your friends about you...")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(NeumorphicColors.lightTextSecondary.opacity(0.6))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 12)
                                }
                                TextEditor(text: $bio)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(NeumorphicColors.lightTextHeadings)
                                    .scrollContentBackground(.hidden)
                                    .focused($focusedField, equals: .bio)
                                    .frame(height: 80)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                            .neumorphicInset(cornerRadius: 16)
                        }
                    }
                    .padding(20)
                    .neumorphicCard(cornerRadius: 26)
                    .padding(.horizontal, 18)
                    
                    // Error
                    if let error = errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(NeumorphicColors.dotRed)
                            Text(error)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(NeumorphicColors.lightTextHeadings)
                        }
                        .padding(14)
                        .neumorphicCard(cornerRadius: 16, accentGlow: NeumorphicColors.dotRed.opacity(0.4))
                        .padding(.horizontal, 18)
                    }
                    
                    // Hint if not checked
                    if !isFormValid && userId.count >= 3 && isIdAvailable == nil {
                        Text("Tap \"Check\" to verify your User ID")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(NeumorphicColors.lightTextSecondary)
                    }
                    
                    // Submit button
                    Button(action: submitProfile) {
                        HStack(spacing: 10) {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text("Let's Go!")
                                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 15, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            Group {
                                if isFormValid {
                                    theme.accentGradient
                                } else {
                                    LinearGradient(
                                        colors: [NeumorphicColors.lightInset, NeumorphicColors.lightInset],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .clipShape(Capsule())
                        .shadow(color: isFormValid ? Color.black.opacity(0.18) : .clear, radius: 8, y: 4)
                    }
                    .disabled(!isFormValid || isSubmitting)
                    .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.95))
                    .padding(.horizontal, 18)
                    .animation(.easeInOut(duration: 0.2), value: isFormValid)
                    
                    Spacer().frame(height: 40)
                }
            }
            .onTapGesture { focusedField = nil }
        }
    }
    
    var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.08))
            .frame(height: 1)
    }
    
    private func checkAvailability() {
        guard userId.count >= 3 else { return }
        isCheckingId = true
        isIdAvailable = nil
        checkError = false
        Task {
            let result = await userController.checkUserIdAvailability(userId: userId)
            await MainActor.run {
                isCheckingId = false
                if let available = result {
                    isIdAvailable = available
                    checkError = false
                } else {
                    // nil means the check itself failed (RLS/network error)
                    isIdAvailable = nil
                    checkError = true
                }
            }
        }
    }
    
    private func submitProfile() {
        guard isFormValid else { return }
        isSubmitting = true
        errorMessage = nil
        Task {
            let success = await userController.createProfile(
                userId: userId,
                username: username,
                bio: bio
            )
            await MainActor.run {
                isSubmitting = false
                if !success {
                    errorMessage = userController.authError ?? "Failed to create profile. Please try again."
                }
            }
        }
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView()
            .environmentObject(UserController())
            .environmentObject(AppThemeController())
    }
}
