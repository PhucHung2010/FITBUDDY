//
//  ContentView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//

import SwiftUI
import AVFoundation
import QuickPoseCore
import QuickPoseSwiftUI

struct ContentView: View {
    @StateObject var theme = AppThemeController()
    @EnvironmentObject var authManager: SupabaseAuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                WideTabView()
//                    .environmentObject(theme)
            } else {
                LoginView()
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabViewController())
            .environmentObject(UserController())
            .environmentObject(SupabaseAuthManager())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
