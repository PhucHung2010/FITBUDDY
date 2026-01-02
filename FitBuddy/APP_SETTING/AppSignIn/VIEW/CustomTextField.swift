//
//  CustomTextField.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/9/25.
//

import SwiftUI

struct CustomTextfield: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Username", text: $text)
            .padding(16)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke()
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
    }
}
