//
//  FeedbackPickerView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 24/06/2025.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct FeedbackPickerView: View {
    @EnvironmentObject var theme: AppThemeController
//    @State private var soundLevel: Float = getCurrentVolume()
    @State private var showTurnOnSoundNotification: Bool = true
    
    var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var targetParameter: TargetExerciseParameterStorage?
    
        @State private var soundLevel: Float = AVAudioSession.sharedInstance().outputVolume * 100
          @State private var audioSession = AVAudioSession.sharedInstance()
            
            // Giữ lại observer
            @State private var volumeObservation: NSKeyValueObservation?
    

    var body: some View {
        VStack(spacing: 5) {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                    exercisePerformance.feedback.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Feedback")
                }
                .font(.system(size: 25, weight: .heavy))
                .foregroundColor((exercisePerformance.feedback == false) ? theme.main.accent : Color.lightOffWhite)
                .shadow(radius: 3)
                .frame(width: UIScreen.main.bounds.width - 100, height: 40)
                .background {
                    if !(exercisePerformance.feedback == false) {
                        theme.main.accent
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    } else {
                        BlurView(style: theme.main.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    }
                }
                .minimumScaleFactor(0.2)
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if showTurnOnSoundNotification && exercisePerformance.feedback {
                Text("Please turn on apropriate sound level")
                    .font(.system(size: 15))
                    .foregroundColor(theme.main.text)
                    .transition(.scale)
                    .onChange(of: soundLevel) { newValue in
                        withAnimation(.spring(duration: 0.4, bounce: 0.4)) {
                            showTurnOnSoundNotification = false
                        }
                    }
            }
            
            if exercisePerformance.feedback {
                HStack(spacing: 15) {
                    CustomSlider($soundLevel,
                                 sliderWidth: UIScreen.main.bounds.width - 160,
                                 onEditingChanged: {
                        FeedbackPickerView.setSystemVolume(self.soundLevel / 100)
                    })
                    
                    Image(systemName: "speaker.wave.1")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(theme.main.accent)
                }
                .transition(.scale)
                .padding(.top, 10)
                .padding(.bottom, 5)
            }
        }
        .mask(RoundedRectangle(cornerRadius: 20))
        .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2))
        .onAppear {
            self.targetParameter = TargetExerciseParameterStorage.loadTargetParameter(for: self.category?.name ?? "", in: viewContext)
            if let feedback = targetParameter?.feedback {
                self.exercisePerformance.feedback = feedback
            }
            
            do {
                try audioSession.setCategory(.ambient, mode: .default, options: [])
                try audioSession.setActive(true)
            } catch {
                print("Audio session setup failed: \(error)")
            }
            
            // Quan sát thay đổi volume qua KVO
            volumeObservation = audioSession.observe(\.outputVolume, options: [.new]) { session, change in
                if let newValue = change.newValue {
                    DispatchQueue.main.async {
                        soundLevel = newValue * 100
                    }
                }
            }
        }
        .onDisappear {
            volumeObservation?.invalidate()
            volumeObservation = nil
            
            targetParameter?.feedback = exercisePerformance.feedback
            try? viewContext.save()
        }
    }
    

    
    
    
    
    
    
    
    
    
    
    static func setSystemVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.setValue(volume, animated: true)
        }
    }

    static func getCurrentVolume() -> Float {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [])
            try audioSession.setActive(true)
            return audioSession.outputVolume
        } catch {
//            print("Audio session setup failed: \(error)")
            return 0.0
        }

    }
}

struct FeedbackPickerView_Previews: PreviewProvider {
    static var previews: some View {
        @State var category = FitnessExerciseCategory().categories.first
        FeedbackPickerView(category: category, exercisePerformance: FitnessExercisePerformance())
            .environmentObject(AppThemeController())
    }
}
