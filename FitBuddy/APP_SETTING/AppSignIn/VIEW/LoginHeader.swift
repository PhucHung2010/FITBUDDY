//
//  LoginHeader.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/9/25.
//

import SwiftUI

struct LoginHeader: View {
    var body: some View {
        VStack {
            Text("Hello Again!")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding()
            
            Text("Welcome to back, You've \nbeen missed")
                .multilineTextAlignment(.center)
        }
    }
}
