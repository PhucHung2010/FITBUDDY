//
//  FitBuddyApp.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//
import Foundation
import SwiftUI
import GoogleSignIn

@main
struct FitBuddyApp: App {
    @StateObject var userController = UserController()
    @StateObject var supabaseAuthManager = SupabaseAuthManager()
    @StateObject var socialManager = SocialManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .environmentObject(userController)
                .environmentObject(supabaseAuthManager)
                .environmentObject(socialManager)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
