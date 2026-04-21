//
//  AppSettingView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 03/06/2025.
//

import SwiftUI
import AVFoundation
import QuickPoseCore
import QuickPoseSwiftUI
import AVFoundation
import AudioToolbox
import Foundation

enum DemoFeatures: String, CaseIterable {
    case handDetection = "Hand Detection"
    case fullBodyTracking = "Full Body Tracking"
    case keypointTracking = "Keypoint Tracking"
    case fullBodyAngle = "Full Body Angle"
    case faceTracking = "Face Tracking"
    
    func featureSystemImage(for feature: DemoFeatures) -> String {
        switch feature {
        case .handDetection:
            return "hand.raised.fill"
        case .keypointTracking:
            return "dot.viewfinder"
        case .fullBodyTracking:
            return "figure.arms.open"
        case .fullBodyAngle:
            return "angle"
        case .faceTracking:
            return "face.dashed.fill"
        }
    }
}

class DemoFeaturesPerformance: PoseDetection {
    @Published var controller: [QuickPose.Feature]?
    @Published var modelConfig: QuickPose.ModelConfig?
    @Published var feedbackText: String?
    @Published var started: Bool = false
    
    init(controller: [QuickPose.Feature]? = nil) {
        self.controller = controller
    }
    
    private let demoStyle: QuickPose.Style = QuickPose.Style(relativeFontSize: 0.8, relativeArcSize: 0.4, relativeLineWidth: 1.3)
    private let fullBodyStyle: QuickPose.Style = QuickPose.Style(relativeFontSize: 0.9, relativeArcSize: 0.3, relativeLineWidth: 1)
    
    func setController(to feature: DemoFeatures) {
        switch feature {
        case .handDetection:
            controller = [.raisedFingers()]
            modelConfig = QuickPose.ModelConfig(detailedFaceTracking: false, detailedHandTracking: true)
        case .keypointTracking:
            controller = [.showPoints(style: demoStyle)]
            modelConfig = QuickPose.ModelConfig(detailedFaceTracking: false, detailedHandTracking: true)
        case .fullBodyTracking:
            controller = [.overlay(.wholeBody, style: demoStyle)]
            modelConfig = QuickPose.ModelConfig(detailedFaceTracking: false, detailedHandTracking: false)
        case .fullBodyAngle:
            controller = [.rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false), style: fullBodyStyle),
                          .rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true), style: fullBodyStyle),
                          .rangeOfMotion(.elbow(side: .left, clockwiseDirection: false), style: fullBodyStyle),
                          .rangeOfMotion(.elbow(side: .right, clockwiseDirection: true), style: fullBodyStyle),
                          .rangeOfMotion(.hip(side: .left, clockwiseDirection: false), style: fullBodyStyle),
                          .rangeOfMotion(.hip(side: .right, clockwiseDirection: true), style: fullBodyStyle),
                          .rangeOfMotion(.knee(side: .left, clockwiseDirection: false), style: fullBodyStyle),
                          .rangeOfMotion(.knee(side: .right, clockwiseDirection: true), style: fullBodyStyle),
//                          .rangeOfMotion(.neck(clockwiseDirection: false), style: demoStyle),
                          .rangeOfMotion(.back(clockwiseDirection: false), style: fullBodyStyle)]
            
            modelConfig = QuickPose.ModelConfig(detailedFaceTracking: false, detailedHandTracking: false)
        case .faceTracking:
            controller = [.showPoints(style: demoStyle)]
            modelConfig = QuickPose.ModelConfig(detailedFaceTracking: true, detailedHandTracking: false)
        }
    }
    
    func perform() {
        if controller != nil && modelConfig != nil {
            quickPose.start(features: controller!, modelConfig: self.modelConfig!, onFrame: { status, image, features, feedback, landmarks in
                switch status {
                    case .success:
                        DispatchQueue.main.sync {
                            self.overlayImage = image
                        }
                        if let result = features.values.first  {
                            DispatchQueue.main.sync {
                                self.feedbackText = result.stringValue
                            }
                        } else {
                            DispatchQueue.main.sync {
                                self.feedbackText = "Demo"
                            }
                        }
                    case .noPersonFound:
                        DispatchQueue.main.sync {
                            self.feedbackText = "Stand in view";
                        }
                    case .sdkValidationError:
                        DispatchQueue.main.sync {
                            self.feedbackText = "Be back soon";
                        }
                }
            })
        }
    }
}

struct AppSettingView: View {
    @ObservedObject var exercisePerformance: DemoFeaturesPerformance = DemoFeaturesPerformance()
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var tabbar: TabViewController
    @State private var performanceView: Bool = false
    
    
    var body: some View {
        ZStack {
            if performanceView == false {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        AppHeadingView(title: "Setting")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30)
                        VStack(spacing: 3) {
                            Divider().padding(.horizontal)
                            Text("User")
                                .font(.system(size: 25, weight: .heavy, design: .rounded))
                                .foregroundColor(theme.main.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 30)
                            UserView()
                        }
                        VStack(spacing: 3) {
                            Divider().padding(.horizontal)
                            Text("Theme")
                                .font(.system(size: 25, weight: .heavy, design: .rounded))
                                .foregroundColor(theme.main.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 30)
                            ThemeSettingView()
                        }
                        VStack(spacing: 3) {
                            Divider().padding(.horizontal)
                            Text("Demo features")
                                .font(.system(size: 25, weight: .heavy, design: .rounded))
                                .foregroundColor(theme.main.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 30)
                            DemoFeatureOptionView(performanceView: $performanceView, exercisePerformance: exercisePerformance)
                        }
                    }
                }
                .transition(.move(edge: .leading))
            }
            else {
                DemoDetectionView(exercisePerformance:  exercisePerformance, performanceView: $performanceView)
                    .transition(.move(edge: .trailing))
            }
        }
        .background(AppBackground())
        .navigationBarBackButtonHidden(true)
    }
}


struct DemoDetectionView: View {
    @ObservedObject var exercisePerformance: DemoFeaturesPerformance
    @EnvironmentObject var tabbar: TabViewController
    @EnvironmentObject var theme: AppThemeController
    @Binding var performanceView: Bool
    
    @State private var startView: Bool = true
    
    var body: some View {
        ZStack {
            QuickPoseCameraSwitchView(
                useFrontCamera: $exercisePerformance.frontCamera,
                delegate: exercisePerformance.quickPose,
                frameRate: $exercisePerformance.frameRates)
                    .ignoresSafeArea()
            QuickPoseOverlayView(overlayImage: $exercisePerformance.overlayImage)
                .ignoresSafeArea()
            topBar
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .overlay(alignment: .center) {
            
        }
    }
    
    
    var topBar: some View {
        HStack(spacing: 20) {
            Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                        exercisePerformance.quickPose.stop()
                        exercisePerformance.controller = nil
                        performanceView = false
                    }
            }) {}
                .buttonStyle(ScaledButtonStyle_OffColorText(text: "Finish", originColor: .green.opacity(0.8), offColor: .offWhite, textFont: 30, scaleRadius: 0.7, animationDuration: 0.2))
            
            Button(action: {
                Task {
                    withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                        exercisePerformance.frontCamera.toggle()
                    }
                }
            }) {}
                .buttonStyle(ScaledButtonStyle_OffColorText(text: "Camera", originColor: .Orange.opacity(0.8), offColor: .offWhite, textFont: 30, scaleRadius: 0.7, animationDuration: 0.2))
            
            
            if let feedbackText = exercisePerformance.feedbackText {
                Text(feedbackText)
                    .font(.system(size: 26, weight: .semibold)).foregroundColor(theme.main.text)
            }
        }
        .frame(height: 50)
        .padding(.horizontal)
        .background(BlurRoundedBackground())
    }
}

struct AppSettingView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingView()
            .environmentObject(UserController())
            .environmentObject(AppThemeController())
            .environmentObject(TabViewController())
    }
}
