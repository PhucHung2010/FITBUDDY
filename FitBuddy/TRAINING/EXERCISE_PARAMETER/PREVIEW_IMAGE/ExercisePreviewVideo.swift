//
//  ExercisePreviewVideo.swift
//  FitBuddy
//
//  Auto-playing exercise preview — shows GIF if available, otherwise video.
//

import SwiftUI
import AVKit
import AVFoundation

struct ExercisePreviewVideo: View {
    @EnvironmentObject var theme: AppThemeController
    let videoStrings: [String]
    let gifName: String?
    let gifSubdirectory: String?
    @State private var players: [AVPlayer] = []
    
    init(videoStrings: [String], gifName: String? = nil, gifSubdirectory: String? = nil) {
        self.videoStrings = videoStrings
        self.gifName = gifName
        self.gifSubdirectory = gifSubdirectory
    }
    
    private let previewWidth = UIScreen.main.bounds.width - 30
    
    var body: some View {
        VStack(spacing: 0) {
            if let gifName = gifName {
                // Show GIF preview
                GIFImageView(gifName: gifName, subdirectory: gifSubdirectory)
                    .frame(width: previewWidth, height: previewWidth)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else if !players.isEmpty {
                // Fallback to video preview
                TabView {
                    ForEach(players.indices, id: \.self) { index in
                        FillVideoPlayer(player: players[index])
                            .frame(width: previewWidth,
                                   height: previewWidth * 4 / 3)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .onAppear {
                                NotificationCenter.default.addObserver(
                                    forName: .AVPlayerItemDidPlayToEndTime,
                                    object: players[index].currentItem,
                                    queue: .main
                                ) { _ in
                                    players[index].seek(to: .zero)
                                    players[index].play()
                                }
                                players[index].isMuted = true
                                players[index].play()
                            }
                            .onDisappear {
                                players[index].pause()
                            }
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .frame(width: previewWidth,
                       height: previewWidth * 4 / 3)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .background(BlurRoundedBackground(cornerRadius: 25))
        .onAppear {
            if gifName == nil {
                loadPlayers()
            }
        }
    }
    
    private func loadPlayers() {
        guard players.isEmpty else { return }
        for video in videoStrings {
            if let url = Bundle.main.url(forResource: video, withExtension: "mp4")
                        ?? Bundle.main.url(forResource: video, withExtension: "MOV")
                        ?? Bundle.main.url(forResource: video, withExtension: "mov") {
                players.append(AVPlayer(url: url))
            }
        }
    }
}

/// A UIViewRepresentable that uses AVPlayerLayer with .resizeAspectFill
/// to fill the entire frame without black bars (crops edges if needed).
struct FillVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerFillView {
        let view = PlayerFillView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: PlayerFillView, context: Context) {
        uiView.playerLayer.player = player
    }
}

class PlayerFillView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
}
