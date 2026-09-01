//
//  PoseDetectionView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//

import SwiftUI
import AVFoundation
import QuickPoseCore
import QuickPoseSwiftUI
import AVFoundation
import AudioToolbox
import Foundation

struct TotalExerciseParameter {
    var totalCorrect: Int
    var totalIncorrect: Int
    var totalTime: Int
    var feedbackText: [String]?
}

enum exerciseStatus {
    case setting
    case traning
    case summary
}

class PoseDetection: ObservableObject {
    @Published var quickPose = QuickPose(sdkKey: "01JWQSJ34XD8XG69XDKQ49HJK9")
    @Published var frameRates: Double? = 60
    @Published var frontCamera: Bool = true
    @Published var showArc: Bool = true
    @Published var overlayImage: UIImage?
    
    /// Tracks whether the QuickPose ML model has been loaded and is ready for inference.
    /// Set to true after the first successful frame callback from quickPose.start().
    @Published var isModelReady: Bool = false
    
    /// Prepares the QuickPose model by performing a lightweight start to warm up TensorFlow Lite.
    /// Call this early (e.g. when entering a contest detail view) so the model is loaded
    /// by the time the user starts exercising.
    func prepareModel(modelConfig: QuickPose.ModelConfig = QuickPose.ModelConfig(detailedFaceTracking: false, detailedHandTracking: false)) {
        guard !isModelReady else { return }
        // Start with a minimal feature to trigger model loading, then stop once ready
        let warmupFeature: [QuickPose.Feature] = [.overlay(.wholeBody)]
        self.quickPose.start(features: warmupFeature, modelConfig: modelConfig) { [weak self] status, _, _, _, _ in
            guard let self = self else { return }
            switch status {
            case .success, .noPersonFound:
                if !self.isModelReady {
                    DispatchQueue.main.async {
                        self.isModelReady = true
                    }
                    self.quickPose.stop()
                }
            @unknown default:
                break
            }
        }
    }

    func playTing() {
        AudioServicesPlaySystemSound(1113)
    }
    func playTing2() {
        AudioServicesPlaySystemSound(1115)
    }
}










struct PoseDetectionView: View {
    @EnvironmentObject var theme: AppThemeController
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    var body: some View {
        ZStack {
            QuickPoseCameraSwitchView(
                useFrontCamera: $exercisePerformance.frontCamera,
                delegate: exercisePerformance.quickPose,
                frameRate: $exercisePerformance.frameRates)
            .ignoresSafeArea()
            if !showCountdown {
                QuickPoseOverlayView(overlayImage: $exercisePerformance.overlayImage)
                    .ignoresSafeArea()
                StatusBarView(controller: exercisePerformance)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            
            if showCountdown {
                BlurView(style: theme.main.ultraThinMaterial)
                    .ignoresSafeArea()
                    .overlay {
                        Text("\(countdownValue)")
                            .font(.system(size: 200, weight: .heavy, design: .rounded))
                            .foregroundColor(.Orange)
                            .transition(.scale.combined(with: .opacity))
                    }
                    .transition(.opacity)
            }
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            finishExercise()
            repeatTimeCounter = false
        }
        .onChange(of: showCountdown) {_ in
            if !showCountdown {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if !repeatTimeCounter || exercisePerformance.exerciseStatus != .traning {
                        timer.invalidate()
                    } else {
                        exercisePerformance.totalTime += 1
                        if let targetTime = exercisePerformance.targetTime, targetTime > 0, exercisePerformance.totalTime >= targetTime {
                            timer.invalidate()
                            AudioServicesPlaySystemSound(1114)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                exercisePerformance.quickPose.stop()
                                exercisePerformance.exerciseStatus = .summary
                            }
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 1), value: showCountdown)
    }
    
    
    @State private var countdownValue: Int = 3
    @State private var showCountdown: Bool = true
    @State private var repeatTimeCounter: Bool = true
    func startCountdown() {
        countdownValue = 3
        showCountdown = true
        repeatTimeCounter = true
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownValue > 1 {
                countdownValue -= 1
            } else {
                timer.invalidate()
                showCountdown = false
                startExercise()
            }
        }
    }
    
    func startExercise() {
        exercisePerformance.updateFeedback(newFeedback: "Exercise started")
        exercisePerformance.perform()
    }
    func finishExercise() {
        exercisePerformance.quickPose.stop()
        exercisePerformance.updateFeedback(newFeedback: "Exercise finished")
    }
}



struct PoseDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        PoseDetectionView(exercisePerformance: FitnessExercisePerformance())
            .environmentObject(AppThemeController())
    }
}

//struct PoseDetectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var category = ExerciseCategory().categories.first
//        TrainingView(category: $category,
//                     exercisePerformance: FitnessExercisePerformance())
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}

