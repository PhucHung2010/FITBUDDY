//
//  CameraChoice.swift
//  FitBuddy
//
//  Created by tai nguyen huu on 7/10/25.
//

import SwiftUI
import Foundation


enum CameraOption: String, CaseIterable {
    case front = "Front"
    case back = "Back"
}
enum FrameRateOption: Double, CaseIterable {
    case low = 30.0
    case medium = 60.0
    case high = 120.0

    static func getFrameRateOption(from value: Double) -> FrameRateOption {
        return FrameRateOption.allCases.first { $0.rawValue == value } ?? .medium
    }
}


struct CameraOptionView: View {
    @EnvironmentObject var theme: AppThemeController
    
    var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    @Environment(\.managedObjectContext) private var viewContext
    @State var targetParameter: TargetExerciseParameterStorage?
    
    @State var showCameraOption: Bool = false
    @Namespace private var animation
    @Namespace private var animation2
    @State var currentCameraOption = CameraOption.back
    @State var currentFrameRateOption = FrameRateOption.medium
    
    var body: some View {
        VStack {
            VStack {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                        showCameraOption.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Camera")
                    }
                    .font(.system(size: 25, weight: .heavy))
                    .foregroundColor(!showCameraOption ? theme.main.accent : Color.lightOffWhite)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 40)
                    .background {
                        if showCameraOption {
                            theme.main.accent
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 6)
                        } else {
                            BlurView(style: theme.main.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 6)
                        }
                    }
                }
                .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                
                if showCameraOption {
                    cameraToggle
                    frameRateToggle
                }
            }
            .mask(RoundedRectangle(cornerRadius: 20))
            .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2, style: .systemMaterialLight))
        }
        .onAppear {
            self.targetParameter = TargetExerciseParameterStorage.loadTargetParameter(for: self.category?.name ?? "", in: viewContext)
            if let target = targetParameter {
                if target.camera {
                    self.exercisePerformance.frontCamera = true
                    self.currentCameraOption = .front
                } else {
                    self.exercisePerformance.frontCamera = false
                    self.currentCameraOption = .back
                }
                
                self.exercisePerformance.frameRates = target.frameRate
                self.currentFrameRateOption = FrameRateOption.getFrameRateOption(from: target.frameRate)
            }
        }
        .onDisappear {
            targetParameter?.camera = exercisePerformance.frontCamera
            targetParameter?.frameRate = exercisePerformance.frameRates ?? Double(60)
            try? viewContext.save()
        }
    }

    var cameraToggle: some View {
        HStack(spacing: 0) {
            ForEach(CameraOption.allCases, id: \.rawValue) { cameraOption in
                HStack(spacing: 5) {
                    if cameraOption == CameraOption.front {
                        Image(systemName: "web.camera.fill")
                            .font(.system(size: 17, weight: .bold))
                    } else {
                        Image(systemName: "iphone.rear.camera")
                            .font(.system(size: 17, weight: .bold))
                    }
                    Text(cameraOption.rawValue)
                        .font(.system(size: 15, weight: .heavy))
                }
                .foregroundColor(currentCameraOption == cameraOption ? theme.main.accent.opacity(1) == theme.main.mainColor ? .white : theme.main.mainColor : theme.main.accent)
                .shadow(radius: 2)
                .scaleEffect(currentCameraOption == cameraOption ? 1.3 : 1)
                .padding(.vertical, 10)
                .frame(width: (UIScreen.main.bounds.width - 150) / 2)
                .background {
                    if currentCameraOption == cameraOption {
                        theme.main.accent
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.0001))
                    }
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                        currentCameraOption = cameraOption
                    }
                    if currentCameraOption == CameraOption.front {
                        if currentFrameRateOption == .high {
                            currentFrameRateOption = .medium
                            exercisePerformance.frameRates = currentFrameRateOption.rawValue
                        }
                        exercisePerformance.frontCamera = true
                    } else {
                        exercisePerformance.frontCamera = false
                    }
                }
            }
        }
        .padding(3)
        .background(
            BlurView(style: theme.main.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(radius: 4)
        )
        .transition(.scale)
    }
    
    var frameRateToggle: some View {
        HStack(spacing: 0) {
            ForEach(FrameRateOption.allCases, id: \.rawValue) { frameRateOption in
                if currentCameraOption != .front || frameRateOption != FrameRateOption.high {
                    Text("\(Int(frameRateOption.rawValue))")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(currentFrameRateOption == frameRateOption ? theme.main.mainColor : theme.main.accent)
                        .shadow(radius: 2)
                        .scaleEffect(currentFrameRateOption == frameRateOption ? 1.3 : 1)
                        .padding(.vertical, 10)
                        .frame(width: (UIScreen.main.bounds.width - 150) / 2)
                        .background {
                            if currentFrameRateOption == frameRateOption {
                                theme.main.accent
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(radius: 4)
                            } else {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.0001))
                            }
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 1), value: currentFrameRateOption)
                        .transition(.scale)
                        .onTapGesture {
                            currentFrameRateOption = frameRateOption
                            exercisePerformance.frameRates = currentFrameRateOption.rawValue
                        }
                }
            }
        }
        .padding(3)
        .mask(RoundedRectangle(cornerRadius: 20))
        .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2, style: .systemMaterialLight))
        .transition(.scale)
        .animation(.spring(response: 0.5, dampingFraction: 1), value: currentCameraOption)
    }
}

struct CameraChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground()
            @State var category: Category?
            CameraOptionView(category: category, exercisePerformance: FitnessExercisePerformance())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(AppThemeController())
        }
    }
}
