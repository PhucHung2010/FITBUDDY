//
//  TrainingView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 26/06/2025.
//

import SwiftUI
import CoreData

struct TrainingView: View {
    @Binding var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    var body: some View {
        ZStack {
            if exercisePerformance.exerciseStatus == .setting {
                ExerciseParameterSettingView(category: $category,
                                             exercisePerformance: exercisePerformance)
                .transition(.move(edge: .leading))
            }
            else if exercisePerformance.exerciseStatus == .traning {
                PoseDetectionView(exercisePerformance: exercisePerformance)
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
            }
            else if exercisePerformance.exerciseStatus == .summary {
                SummaryView(category: category, exercisePerformance: exercisePerformance)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 1), value: exercisePerformance.exerciseStatus)
    }
}

struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        @State var category = FitnessExerciseCategory().categories.first
        TrainingView(category: $category,
                     exercisePerformance: FitnessExercisePerformance())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AppThemeController())
    }
}
