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
    @EnvironmentObject var userController: UserController
    var body: some View {
        Group {
            switch userController.authState {
            case .loading:
                ZStack {
                    AppBackground()
                    ProgressView()
                }
            case .unauthenticated:
                LoginPageView()
            case .needsProfile:
                ProfileSetupView()
            case .authenticated:
                WideTabView()
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabViewController())
            .environmentObject(UserController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
