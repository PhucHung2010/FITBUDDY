//
//  InstructionView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 24/06/2025.
//

import SwiftUI
import AVKit


struct InstructionView: View {
    let category: Category
    var body: some View {
        VStack {
            CategoryInstructionVideoView(videoStrings: category.videos)
            CategoryDescriptionView(description: category.description)
            CategoryInstructionView(instructions: category.instruction)
        }
        .transition(.scale)
    }
}



struct CategoryInstructionVideoView: View {
    @EnvironmentObject var theme: AppThemeController
    let instructionVideoPlayers: [String]
    @State var showInstructionVideos: Bool
    @State var players: [AVPlayer]
    
    init(videoStrings: [String]) {
        self.instructionVideoPlayers = videoStrings
        self.players = []
        self.showInstructionVideos = false
    }
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                    showInstructionVideos.toggle()
                }
                if !showInstructionVideos {
                    for player in players {
                        player.pause()
                        player.seek(to: .zero) // Nếu bạn muốn reset về đầu
                    }
                }
            }) {
                HStack {
                    Image(systemName: "video.fill")
                    Text("Video")
                }
                .font(.system(size: 25, weight: .heavy))
                .foregroundColor((showInstructionVideos) ? Color.lightOffWhite : Color.Orange)
                .shadow(radius: 3)
                .frame(width: UIScreen.main.bounds.width - 40, height: 40)
                .background {
                    if (showInstructionVideos) {
                        Color.Orange
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 4)
                    } else {
                        BlurView(style: theme.main.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    }
                }
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if showInstructionVideos {
                TabView {
                    ForEach(players, id: \.self) {player in
                        VideoPlayer(player: player)
                            .frame(width: UIScreen.main.bounds.width - 40,
                                   height: (UIScreen.main.bounds.width - 40) * 3 / 2)
                            .ignoresSafeArea()
                            .onAppear() {
                                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                                    player.seek(to: .zero)
                                    player.play()
                                }
                                player.play()
                            }
                            .onDisappear() {
                                player.pause()
                            }
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .transition(.scale)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(width: UIScreen.main.bounds.width - 40,
                       height: (UIScreen.main.bounds.width - 40) * 3 / 2)
            }
        }
        .mask(RoundedRectangle(cornerRadius: 20))
        .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2))
        .onAppear {
            initVideoStrings()
        }
    }
    
    func initVideoStrings() {
        for video in instructionVideoPlayers {
            players.append(AVPlayer(url: Bundle.main.url(forResource: "\(video)", withExtension: "MOV")!))
        }
    }
}

struct CategoryDescriptionView: View {
    @EnvironmentObject var theme: AppThemeController
    let description: String
    @State var showDescription: Bool = false
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                  showDescription.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "quote.opening")
                    Text("Description")
                }
                .font(.system(size: 25, weight: .heavy))
                .foregroundColor((showDescription) ? Color.lightOffWhite : Color.Orange)
                .shadow(radius: 3)
                .frame(width: UIScreen.main.bounds.width - 40, height: 40)
                .background {
                    if (showDescription) {
                        Color.Orange
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 4)
                    } else {
                        BlurView(style: theme.main.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    }
                }
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if showDescription {
                ScrollView {
                    Text(description)
                        .foregroundColor(theme.main.text)
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                        .transition(.scale)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: UIScreen.main.bounds.width - 55, height: 250)
                .transition(.scale)
            }
        }
        .mask(RoundedRectangle(cornerRadius: 20))
        .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2))
    }
}


struct CategoryInstructionView: View {
    @EnvironmentObject var theme: AppThemeController
    let instructions: [String]
    @State var showDescription: Bool = false
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                    showDescription.toggle()
                }
                
            }) {
                HStack {
                    Image(systemName: "key.horizontal.fill")
                    Text("Instruction")
                }
                .font(.system(size: 25, weight: .heavy))
                .foregroundColor((showDescription) ? Color.lightOffWhite : Color.Orange)
                .shadow(radius: 3)
                .frame(width: UIScreen.main.bounds.width - 40, height: 40)
                .background {
                    if (showDescription) {
                        Color.Orange
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 4)
                    } else {
                        BlurView(style: theme.main.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    }
                }
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if showDescription {
                ScrollView {
                    VStack {
                        ForEach(instructions, id: \.self) {instruction in
                            Text(instruction)
                                .foregroundColor(theme.main.text)
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .multilineTextAlignment(.center)
                            Divider()
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: UIScreen.main.bounds.width - 50, height: 250)
                .transition(.scale)
            }
        }
        .mask(RoundedRectangle(cornerRadius: 20))
        .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2, style: .systemMaterialLight))
    }
}


struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        if let category = FitnessExerciseCategory().categories.first {
            InstructionView(category: category)
                .environmentObject(TabViewController())
                .environmentObject(AppThemeController())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
