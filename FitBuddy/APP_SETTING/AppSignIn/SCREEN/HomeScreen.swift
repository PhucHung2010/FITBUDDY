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
            if let image = userController.user?.imageURL {
                AsyncImage(url: URL(string: image)) { phase in
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
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
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

