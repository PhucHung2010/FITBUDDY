//
//  AngleValue.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 22/8/25.
//

import SwiftUI
import Foundation


enum ArcSizeOption: String, CaseIterable {
    case show = "Show"
    case hide = "Hide"
}


struct ArcSizePickerView: View {
    @EnvironmentObject var theme: AppThemeController
    
    var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    @Environment(\.managedObjectContext) private var viewContext
    @State var targetParameter: TargetExerciseParameterStorage?
    
    @State var showArcOtion: Bool = false
    @Namespace private var animation
    @State var currentArcOtion = ArcSizeOption.show
    
    var body: some View {
        VStack {
            VStack {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                        showArcOtion.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "angle")
                        Text("Arc")
                    }
                    .font(.system(size: 25, weight: .heavy))
                    .foregroundColor(!showArcOtion ? Color.Orange : Color.lightOffWhite)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 40)
                    .background {
                        if showArcOtion {
                            Color.Orange
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
                
                if showArcOtion {
                    cameraToggle
                }
            }
            .mask(RoundedRectangle(cornerRadius: 20))
            .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2, style: .systemMaterialLight))
        }
        .onAppear {
            self.targetParameter = TargetExerciseParameterStorage.loadTargetParameter(for: self.category?.name ?? "", in: viewContext)
            if let target = targetParameter {
                if target.arc {
                    self.exercisePerformance.showArc = true
                    self.currentArcOtion = .show
                } else {
                    self.exercisePerformance.showArc = false
                    self.currentArcOtion = .hide
                }
            }
        }
        .onDisappear {
            targetParameter?.arc = exercisePerformance.showArc
            try? viewContext.save()
        }
    }

    var cameraToggle: some View {
        HStack(spacing: 0) {
            ForEach(ArcSizeOption.allCases, id: \.rawValue) { arcShow in
                HStack(spacing: 5) {
                    Text(arcShow.rawValue)
                        .font(.system(size: 20, weight: .semibold))
                }
                .foregroundColor(currentArcOtion == arcShow ? theme.main.mainColor : .Orange)
                .shadow(radius: 2)
                .scaleEffect(currentArcOtion == arcShow ? 1.3 : 1)
                .frame(width: 120, height: 35)
                .background {
                    if currentArcOtion == arcShow {
                        RoundedRectangle(cornerRadius: 45)
                            .fill(Color.Orange)
                            .matchedGeometryEffect(id: "ActiveCameraOption", in: animation)
                            .shadow(radius: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 45)
                            .fill(Color.white.opacity(0.0001))
                    }
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                        currentArcOtion = arcShow
                    }
                    if currentArcOtion == ArcSizeOption.show {
                        exercisePerformance.showArc = true
                    } else {
                        exercisePerformance.showArc = false
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
}

struct ArcSizePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground()
                .environmentObject(AppThemeController())
            @State var category: Category?
            ArcSizePickerView(category: category, exercisePerformance: FitnessExercisePerformance())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(AppThemeController())
        }
    }
}
