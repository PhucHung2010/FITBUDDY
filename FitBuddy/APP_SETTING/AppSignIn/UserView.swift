//
//  UserView.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/9/25.
//

import SwiftUI
import Foundation


struct UserView: View {
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var authManager: SupabaseAuthManager
    @EnvironmentObject var theme: AppThemeController
    @State private var showEditProfile = false
    
    var body: some View {
        VStack(spacing: 10) {
            if authManager.isAuthenticated {
                officialUser
                userBadgesSection
                signOutButton
            } else {
                anonymousUser
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .sheet(isPresented: $showEditProfile) {
            ProfileEditView()
        }
    }
    
    
    var officialUser: some View {
        VStack {
            // User avatar from Google or Supabase
            if let image = authManager.currentUserProfile?.imageURL ?? userController.user?.imageURL ?? authManager.currentUser?.userMetadata["avatar_url"]?.value as? String {
                AsyncImage(url: URL(string: image)) { phase in
                    if let image = phase.image {
                        image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                    }
                }
                .frame(width: 110, height: 110)
                .padding(2)
                .background {
                    BlurView(style: theme.main.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(theme.main.text.opacity(0.6))
                    .frame(width: 110, height: 110)
            }
            VStack {
                Text(authManager.currentUserProfile?.name ?? userController.user?.name ?? authManager.currentUser?.userMetadata["full_name"]?.value as? String ?? "User")
                    .foregroundColor(theme.main.text)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                
                if let username = authManager.currentUserProfile?.username, !username.isEmpty {
                    Text("@\(username)")
                        .foregroundColor(theme.main.text.opacity(0.7))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                }
                
                Text(authManager.currentUserProfile?.email ?? userController.user?.email ?? authManager.currentUser?.email ?? "")
                    .foregroundColor(theme.main.text.opacity(0.7))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                
                if let bio = authManager.currentUserProfile?.bio, !bio.isEmpty {
                    Text(bio)
                        .foregroundColor(theme.main.text)
                        .font(.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .padding(10)
            .background {
                BlurView(style: theme.main.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 2)
            }
            
            Button(action: { showEditProfile = true }) {
                Text("Edit Profile")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(theme.main.text.opacity(0.3))
                    .clipShape(Capsule())
            }
            .padding(.top, 5)
            
        }
        .frame(width: UIScreen.main.bounds.width - 60)
        .padding(.vertical, 5)
        .background() {
            BlurView(style: theme.main.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 4)
        }
    }
    
    @ViewBuilder
    var userBadgesSection: some View {
        if !authManager.userBadges.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Badges")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
                    .padding(.horizontal, 25)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(authManager.userBadges) { badge in
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
            .frame(width: UIScreen.main.bounds.width)
        }
    }
    
    var anonymousUser: some View {
        VStack(spacing: 15) {
            VStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFill()
                    .shadow(radius: 4)
                    .frame(width: 110, height: 110)
                
                Text("Anonymous")
                    .foregroundColor(theme.main.text)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                
            }
            .padding(.vertical, 5)
            .frame(width: UIScreen.main.bounds.width - 60)
            .background {
                BlurView(style: theme.main.ultraThinMaterial).ignoresSafeArea()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width - 40)
        }
    }
    
    var signOutButton: some View {
        Button(action: {
            userController.signOut()
            authManager.logOut()
        }) {
            HStack {
                Text("Sign out")
                    .foregroundColor(theme.main.text)
                    .font(.system(size: 20, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
            }
            .padding(10)
            .background {
                BlurView(style: theme.main.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 45))
                    .shadow(radius: 4)
            }
        }
        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            AppSettingView()
                .environmentObject(UserController(user: UserModel(id: "no",
                                                                  name: "Hưng Nguyễn",
                                                                  email: "nhphung2468@gmail.com",
                                                                  imageURL: "https://lh3.googleusercontent.com/a/ACg8ocL1E5Imyb3wQUfxEZ8GIvyXOjgtU776TXxIxfk2U1b3AtK3h7I=s1000")))
                .environmentObject(AppThemeController())
        }
    }
}
