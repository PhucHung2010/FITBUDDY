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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    FirebaseApp.configure()
                    userController.restorePreviousSignIn()
                }
                .environmentObject(userController)
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
