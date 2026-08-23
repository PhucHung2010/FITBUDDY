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
            AngleBlurPickerView(category: category, exercisePerformance: exercisePerformance)
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

