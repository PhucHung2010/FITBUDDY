//
//  FitBuddyApp.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//
import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

@main
struct FitBuddyApp: App {
    @StateObject var userController = UserController()
    @StateObject var theme = AppThemeController()
    @StateObject var tabController = TabViewController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    userController.handleOAuthCallback(url: url)
                }
                .onAppear {
                    FirebaseApp.configure()
                    userController.restoreSession()
                }
                .environmentObject(userController)
                .environmentObject(theme)
                .environmentObject(tabController)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}



//            if cameraPermissionGranted {
//                    .onAppear {
//                        AVCaptureDevice.requestAccess(for: .video) { accessGranted in
//                            DispatchQueue.main.async {
//                                self.cameraPermissionGranted = accessGranted
//                            }
//                        }
//                    }
//            }
