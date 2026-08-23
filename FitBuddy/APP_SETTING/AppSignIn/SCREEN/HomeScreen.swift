//
//  HomeScreen.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/9/25.
//
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase
import Foundation


struct HomeScreen: View {
    @EnvironmentObject var userController: UserController
    var body: some View {
        VStack {
            if let profile = userController.profile, !profile.avatarUrl.isEmpty {
                AsyncImage(url: URL(string: profile.avatarUrl)) { phase in
                    if let image = phase.image {
                        image
                        .resizable()
                        .scaledToFill()
                    }
                }
                .frame(width: 300, height: 300)
            }
            else {
                Image(systemName: "person.crop.circle.fill.badge.exclamationmark")
                    .frame(width: 300, height: 300)
            }
            
            Button(action: {
                userController.signOut()
            }) {
                Text("Sign Out")
            }
        }
    }
}

struct HomeSreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
            .environmentObject(UserController())
    }
}

