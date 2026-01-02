//
//  UserView.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/9/25.
//

import SwiftUI
import Foundation


struct UserView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var theme: AppThemeController
    var body: some View {
        VStack(spacing: 10) {
            if userController.user == nil {
                anonymousUser
                signInButton
            }
            else {
                officialUser
                signOutButton
            }
        }
        .frame(width: UIScreen.main.bounds.width)
    }
    
    
    var officialUser: some View {
        VStack {
            if let image = userController.user?.imageURL {
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
            }
            VStack {
                Text(userController.user?.name ?? "No name")
                    .foregroundColor(theme.main.text)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                Text(userController.user?.email ?? "khong co")
                    .foregroundColor(theme.main.text)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
            }
            .padding(5)
            .background {
                BlurView(style: theme.main.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 2)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 60)
        .padding(.vertical, 5)
        .background() {
            BlurView(style: theme.main.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 4)
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
    
    var signInButton: some View {
        Button(action: { userController.login() }) {
            HStack {
                Text("Sign in with")
                    .foregroundColor(theme.main.text)
                    .font(.system(size: 20, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                Image("google")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 25, height: 25)
                    .padding(6)
                    .background {
                        Circle().foregroundColor(theme.main.mainColor)
                    }
                    .shadow(radius: 4)
            }
            .padding(5)
            .background {
                BlurView(style: theme.main.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 45))
                    .shadow(radius: 4)
            }
        }
        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
    }
    
    var signOutButton: some View {
        Button(action: { userController.signOut() }) {
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
