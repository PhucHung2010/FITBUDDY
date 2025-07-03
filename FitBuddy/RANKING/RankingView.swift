//
//  RankingView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 03/06/2025.
//

import SwiftUI

struct RankingView: View {
    var body: some View {
        ZStack {
            AppBackground()
            Image(systemName: "medal.fill")
                .font(.system(size: 200))
        }
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView()
    }
}
