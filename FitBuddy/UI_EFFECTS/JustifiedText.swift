//
//  JustifiedText.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 24/06/2025.
//

import Foundation
import SwiftUI

struct JustifiedText: UIViewRepresentable {
    let text: String
    let font: UIFont

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.font = font
        textView.textAlignment = .justified
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = font
    }
}
