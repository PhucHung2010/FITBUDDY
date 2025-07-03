//
//  AppSettingView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 03/06/2025.
//

import SwiftUI

struct AppSettingView: View {
    var body: some View {
        ZStack {
            AppBackground()
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 200))
        }
    }
}

struct AppSettingView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingView()
    }
}
