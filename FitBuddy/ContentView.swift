//
//  ContentView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//

import SwiftUI
import AVFoundation
import QuickPoseCore
import QuickPoseSwiftUI

struct ContentView: View {
    @State var cameraPermissionGranted = false
    var body: some View {
        WideTabView()

//        PoseDetectionView(exercisePerformance:
//                            FitnessExercisePerformance(controller: FitnessExerciseAdjustment(
//                                limbGroups: [
//                                    LimbGroup(name: "ARM",
//                                              acceptedAngleValueDifference: 50,
//                                              left: MovementTarget(feature: .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false)),
//                                                                   correctionStyle: nil,
//                                                                   launchResult: .init(angleValue: 150, angleBlur: 20),
//                                                                   peakResult: .init(angleValue: 30, angleBlur: 20),
//                                                                   middleRangeResultBlur: 20,
//                                                                   launchDirection: .increase,
//                                                                   peakDirection: .decrease),
//                                              right: MovementTarget(feature: .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true)),
//                                                                    correctionStyle: nil,
//                                                                    launchResult: .init(angleValue: 150, angleBlur: 20),
//                                                                    peakResult: .init(angleValue: 30, angleBlur: 20),
//                                                                    middleRangeResultBlur: 20,
//                                                                    launchDirection: .increase,
//                                                                    peakDirection: .decrease))
//                                ],
//                                guardGroups: nil
//                            ))
//        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
