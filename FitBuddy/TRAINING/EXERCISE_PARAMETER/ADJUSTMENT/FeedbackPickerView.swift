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
    
    @State private var soundLevel: Float = getCurrentVolume()
    @ObservedObject var exercisePerformance: FitnessExercisePerformance

    var body: some View {
        VStack(spacing: 15) {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    exercisePerformance.feedback.toggle()
                }
            }) {
                Text("FEEDBACK")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor((exercisePerformance.feedback == false) ? Color.Orange : Color.lightOffWhite)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                    .background {
                        if !(exercisePerformance.feedback == false) {
                            Color.Orange
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 6)
                        } else {
                            Color.lightOffWhite
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 6)
                        }
                    }
                    .minimumScaleFactor(0.2)
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if exercisePerformance.feedback {
                HStack {
                    CustomSlider($soundLevel,
                                 leftButtonWidth: UIScreen.main.bounds.width - (UIScreen.main.bounds.width - 180),
                                 onEditingChanged: {
                        FeedbackPickerView.setSystemVolume(self.soundLevel / 100)
                    })
                    
                    Image(systemName: "wave.3.forward")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.Orange)
                }
                .transition(.offset(y: -50).combined(with: .scale).combined(with: .opacity))
            }
        }
        .padding(5)
        .background {
            BlurView(style: .systemMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 30))
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
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            let volume = audioSession.outputVolume
            return volume
        } catch {
            print("Failed to get current volume: \(error)")
            return 0.0
        }
    }
}

struct FeedbackPickerView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackPickerView(exercisePerformance: FitnessExercisePerformance())
    }
}
