//
//  HomeView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 03/06/2025.
//

import SwiftUI
import AudioToolbox

struct HomeView: View {
    var body: some View {
        ZStack {
            AppBackground()
            Image(systemName: "house").ignoresSafeArea().font(.system(size: 200))
            Button(action: {playTing()}) {
                Text("TAP ME")
                    .font(.system(size: 50))
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.orange)
        }
    }
    
    func playTing() {
        AudioServicesPlaySystemSound(1113)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
