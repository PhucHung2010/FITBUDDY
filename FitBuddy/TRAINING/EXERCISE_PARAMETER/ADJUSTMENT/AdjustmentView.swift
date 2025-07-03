//
//  AdjustmentView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 24/06/2025.
//

import SwiftUI

struct AdjustmentView: View {
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    @State var showRepPickerView: Bool = false
    @State var showTimePickerView: Bool = false
    @State var showFeedbackPickerView: Bool = false
    var body: some View {
        VStack() {
            RepPickerView(exercisePerformance: exercisePerformance)
            TimePickerView(exercisePerformance: exercisePerformance)
            FeedbackPickerView(exercisePerformance: exercisePerformance)
        }
        .frame(width: UIScreen.main.bounds.width - 40)
        .transition(.offset(y: -300).combined(with: .scale.combined(with: .opacity)))
    }
}

struct AdjustmentView_Previews: PreviewProvider {
    static var previews: some View {
        AdjustmentView(exercisePerformance: FitnessExercisePerformance())
    }
}
