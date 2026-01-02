//
//  CustomButton.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/9/25.
//

import SwiftUI

struct CustomButton: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Spacer()
                Text("Login")
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .padding()
        .background(.black)
        .cornerRadius(12)
        .padding()
    }
}
