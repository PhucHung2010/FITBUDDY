//
//  BlurView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 15/06/2025.
//

import Foundation
import SwiftUI


struct VisualEffectBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .regular

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.backgroundColor = .clear
        
        return blurView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // Không cần cập nhật gì thêm
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
