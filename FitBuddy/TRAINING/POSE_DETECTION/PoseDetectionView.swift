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
    
    
    
//    init(targetCount: Int? = nil,
//         targetTime: Int? = nil,
//         feedback: Bool = false,
//         controller: FitnessExerciseAdjustment?,
//         modelConfig: QuickPose.ModelConfig = QuickPose.ModelConfig(
//            detailedFaceTracking: false,
//            detailedHandTracking: false)
//    ) {
//        self.targetCount = targetCount
//        self.targetTime = targetTime
//        self.feedback = feedback
//        self.controller = controller
//        self.modelConfig = modelConfig
//    }
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
                    if !repeatTimeCounter {
                        timer.invalidate()
                    } else {
                        exercisePerformance.totalTime += 1
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

