//
//  TrainingView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 26/06/2025.
//

import SwiftUI

struct TrainingView: View {
    @Binding var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            ExerciseParameterSettingView(category: $category,
                                         exercisePerformance: exercisePerformance)
            .transition(.move(edge: .trailing))
        
            PoseDetectionView(exercisePerformance: exercisePerformance)
                .transition(.move(edge: .trailing))
                
            SummaryView(exercisePerformance: exercisePerformance)
                .transition(.move(edge: .trailing))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: exercisePerformance.exerciseStarted)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: exercisePerformance.exerciseEnded)
    }
}

struct trainingview: View {
    @State var category = ExerciseCategory().categories.first
    var body: some View {
        TrainingView(category: $category,
                     exercisePerformance: FitnessExercisePerformance())
    }
}

struct TrainingView_Previews: PreviewProvider {
    @State var category = ExerciseCategory().categories.first
    static var previews: some View {
        trainingview()
    }
}
