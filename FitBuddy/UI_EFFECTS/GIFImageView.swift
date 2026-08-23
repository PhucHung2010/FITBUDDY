//
//  GIFImageView.swift
//  FitBuddy
//
//  Displays animated GIF from the app bundle using UIKit's UIImageView.
//

import SwiftUI
import WebKit

/// A SwiftUI wrapper for displaying animated GIFs using WKWebView.
/// WKWebView is highly optimized for GIF playback (smooth and memory efficient)
/// which rivals 3rd-party libraries like SDWebImage without needing a package.
struct GIFImageView: UIViewRepresentable {
    let gifName: String
    let subdirectory: String?
    
    init(gifName: String, subdirectory: String? = nil, speedMultiplier: Double = 1.0) {
        self.gifName = gifName
        self.subdirectory = subdirectory
        // WKWebView plays at the native speed of the GIF, which is usually perfectly smooth.
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Make background transparent
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        // Disable interactions
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false
        
        // Prevent intrinsic content size from overriding SwiftUI's frame
        webView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        webView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        webView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        webView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        if let url = Bundle.main.url(
            forResource: gifName,
            withExtension: "gif",
            subdirectory: subdirectory
        ) ?? Bundle.main.url(forResource: gifName, withExtension: "gif") {
            
            // We load the file URL directly to maximize performance and avoid base64 encoding overhead
            let html = """
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0">
                <style>
                    body, html {
                        margin: 0;
                        padding: 0;
                        width: 100%;
                        height: 100%;
                        background-color: transparent;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                    }
                    img {
                        width: 100%;
                        height: 100%;
                        object-fit: cover; /* Equivalent to .scaleAspectFill */
                    }
                </style>
            </head>
            <body>
                <img src="\(url.absoluteString)">
            </body>
            </html>
            """
            
            webView.loadHTMLString(html, baseURL: url.deletingLastPathComponent())
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No update needed for static GIF display
    }
}
