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
            CategoryDescriptionView(description: category.description)
            CategoryInstructionView(instructions: category.instruction)
            CategoryInstructionVideoView(videoStrings: category.videos)
        }
        .frame(width: UIScreen.main.bounds.width - 40)
        .transition(.offset(y: -300).combined(with: .scale.combined(with: .opacity)))
    }
}



struct CategoryInstructionVideoView: View {
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
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showInstructionVideos.toggle()
                }
            }) {
                Text("Instruction video")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor((showInstructionVideos) ? Color.lightOffWhite : Color.Orange)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width - 70, height: 50)
                    .background {
                        if (showInstructionVideos) {
                            Color.Orange
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 6)
                        } else {
                            Color.lightOffWhite
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
                            .frame(width: UIScreen.main.bounds.width - 70,
                                   height: (UIScreen.main.bounds.width - 70) * 3 / 2)
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
                .transition(.offset(y: -100).combined(with: .scale).combined(with: .opacity))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(width: UIScreen.main.bounds.width - 70,
                       height: (UIScreen.main.bounds.width - 70) * 3 / 2)
            }
        }
        .padding(5)
        .background {
            BlurView(style: .systemMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }
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


struct CategoryInstructionView: View {
    let instructions: [String]
    @State var showDescription: Bool = false
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showDescription.toggle()
                }
            }) {
                Text("Instruction")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor((showDescription) ? Color.lightOffWhite : Color.Orange)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width - 70, height: 50)
                    .background {
                        if (showDescription) {
                            Color.Orange
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 6)
                        } else {
                            Color.lightOffWhite
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
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .regular, design: .rounded))
                                .multilineTextAlignment(.center)
                            Divider()
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: UIScreen.main.bounds.width - 70, height: 220)
                .transition(.offset(y: -130).combined(with: .scale.combined(with: .opacity)))
            }
        }
        .padding(5)
        .background {
            BlurView(style: .systemMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }
}


struct CategoryDescriptionView: View {
    let description: String
    @State var showDescription: Bool = false
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showDescription.toggle()
                }
            }) {
                Text("Description")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor((showDescription) ? Color.lightOffWhite : Color.Orange)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width - 70, height: 50)
                    .background {
                        if (showDescription) {
                            Color.Orange
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 6)
                        } else {
                            Color.lightOffWhite
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 6)
                        }
                    }
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if showDescription {
                ScrollView {
                    Text(description)
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                        .transition(.offset(y: -30).combined(with: .scale.combined(with: .opacity)))
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: UIScreen.main.bounds.width - 70, height: 220)
                .transition(.offset(y: -130).combined(with: .scale.combined(with: .opacity)))
            }
        }
        .padding(5)
        .background {
            BlurView(style: .systemMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }
}

struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        if let category = ExerciseCategory().categories.first {
            InstructionView(category: category)
        }
    }
}
