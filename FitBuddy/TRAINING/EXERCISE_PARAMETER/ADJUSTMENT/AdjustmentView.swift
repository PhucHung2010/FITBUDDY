//
//  AdjustmentView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 24/06/2025.
//

import SwiftUI
import CoreData

struct AdjustmentView: View {
    @Binding var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    var body: some View {
        VStack() {
            HStack {
                RepPickerView(category: category, exercisePerformance: exercisePerformance)
                TimePickerView(category: category, exercisePerformance: exercisePerformance)
            }
            .frame(width: UIScreen.main.bounds.width - 100)
            FeedbackPickerView(category: category, exercisePerformance: exercisePerformance)
            CameraOptionView(category: category, exercisePerformance: exercisePerformance)
            ArcSizePickerView(category: category, exercisePerformance: exercisePerformance)
            AngleBlurOptionView(category: category, exercisePerformance: exercisePerformance)
        }
        .transition(.scale)
    }
}

struct AdjustmentView_Previews: PreviewProvider {
    static var previews: some View {
        @State var category: Category?
        AdjustmentView(category: $category, exercisePerformance: FitnessExercisePerformance())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct AngleBlurOptionView: View {
    @EnvironmentObject var theme: AppThemeController
    
    var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var showAngleBlurOption: Bool = false
    @State var blurValue: Float = 15.0
    
    var body: some View {
        VStack {
            VStack {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                        showAngleBlurOption.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "circle.circle")
                        Text("Angle Blur")
                    }
                    .font(.system(size: 25, weight: .heavy))
                    .foregroundColor(!showAngleBlurOption ? Color.Orange : Color.lightOffWhite)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 40)
                    .background {
                        if showAngleBlurOption {
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
                
                if showAngleBlurOption {
                    CustomSlider($blurValue, 100, sliderWidth: UIScreen.main.bounds.width - 150) {
                        UserDefaults.standard.set(Double(blurValue), forKey: "globalAngleBlur")
                    }
                    .padding(.vertical, 10)
                }
            }
            .mask(RoundedRectangle(cornerRadius: 20))
            .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2, style: .systemMaterialLight))
        }
        .onAppear {
            let saved = UserDefaults.standard.double(forKey: "globalAngleBlur")
            self.blurValue = saved > 0.0 ? Float(saved) : 15.0
        }
    }
}

