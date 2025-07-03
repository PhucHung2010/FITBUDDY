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

class PoseDetection: ObservableObject {
    @Published var quickPose = QuickPose(sdkKey: "01JWQSJ34XD8XG69XDKQ49HJK9")
    @Published var modelConfig: QuickPose.ModelConfig
    @Published var frameRates: Double? = 60
    @Published var frontCamera: Bool = true
    @Published var overlayImage: UIImage?
    
    @Published var totalCorrect: Int = 0
    @Published var totalIncorrect: Int = 0
    @Published var targetCount: Int?
    
    @Published var totalTime: Int = 0
    @Published var targetTime: Int?
    
    @Published var feedback: Bool
    @Published var feedbackText: [String]? = ["exercise started"]
    
    @Published var controller: FitnessExerciseAdjustment?
    
    @Published var exerciseStarted: Bool = false
    @Published var exerciseEnded: Bool = false
    
    init(targetCount: Int? = nil,
         targetTime: Int? = nil,
         feedback: Bool = true,
         controller: FitnessExerciseAdjustment?,
         modelConfig: QuickPose.ModelConfig = QuickPose.ModelConfig(
            detailedFaceTracking: false,
            detailedHandTracking: false)
    ) {
        self.targetCount = targetCount
        self.targetTime = targetTime
        self.feedback = feedback
        self.controller = controller
        self.modelConfig = modelConfig
    }
    
    func reinitialize() {
        self.exerciseStarted = false
        self.exerciseEnded = false
        totalCorrect = 0
        totalIncorrect = 0
        totalTime = 0
        feedbackText = []
        
    }
    
    func playTing() {
        AudioServicesPlaySystemSound(1113)
    }
    func playTing2() {
        AudioServicesPlaySystemSound(1115)
    }
}







struct PoseDetectionView: View {
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    var body: some View {
        if exercisePerformance.exerciseStarted && !exercisePerformance.exerciseEnded {
            ZStack {
                QuickPoseCameraSwitchView(
                    useFrontCamera: $exercisePerformance.frontCamera,
                    delegate: exercisePerformance.quickPose,
                    frameRate: $exercisePerformance.frameRates)
                .ignoresSafeArea()
                QuickPoseOverlayView(overlayImage: $exercisePerformance.overlayImage)
                    .ignoresSafeArea()
                StatusBarView(controller: exercisePerformance)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .onAppear {
                exercisePerformance.Performance()
            }
        }
    }
}

//struct PoseDetectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        PoseDetectionView(exercisePerformance: FitnessExercisePerformance())
//    }
//}



