//
//  AngleBlurPickerView.swift
//  FitBuddy
//
//  Created by FitBuddy on 10/08/2025.
//

import SwiftUI

struct AngleBlurPickerView: View {
    var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    @EnvironmentObject var theme: AppThemeController
    
    @State private var angleBlurValue: Float = 15
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "scope")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.Orange)
                Text("Angle Blur")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
                
                Spacer()
                
                Text("±\(Int(angleBlurValue))°")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(.Orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.Orange.opacity(0.15))
                    )
            }
            .padding(.horizontal)
            
            Text("Margin of error for pose detection")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(theme.main.text.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            CustomSlider($angleBlurValue, 50, sliderWidth: UIScreen.main.bounds.width - 100) {
                applyAngleBlur()
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .onAppear {
            loadCurrentAngleBlur()
        }
    }
    
    private func loadCurrentAngleBlur() {
        // Load the current angle blur from the first limb group
        if let firstLimb = exercisePerformance.controller?.limbGroups.first {
            angleBlurValue = Float(firstLimb.left.launchResult.angleBlur)
        }
    }
    
    private func applyAngleBlur() {
        guard exercisePerformance.controller != nil else { return }
        let blur = Double(angleBlurValue)
        
        for index in exercisePerformance.controller!.limbGroups.indices {
            exercisePerformance.controller!.limbGroups[index].left.launchResult.angleBlur = blur
            exercisePerformance.controller!.limbGroups[index].left.peakResult.angleBlur = blur
            exercisePerformance.controller!.limbGroups[index].right.launchResult.angleBlur = blur
            exercisePerformance.controller!.limbGroups[index].right.peakResult.angleBlur = blur
        }
    }
}

struct AngleBlurPickerView_Previews: PreviewProvider {
    static var previews: some View {
        AngleBlurPickerView(
            category: FitnessExerciseCategory().categories.first,
            exercisePerformance: FitnessExercisePerformance()
        )
        .environmentObject(AppThemeController())
    }
}
