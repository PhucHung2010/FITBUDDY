//
//  SummaryView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 26/06/2025.
//

import SwiftUI

struct SummaryView: View {
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    let screenWidth = UIScreen.main.bounds.width - 40

    init(exercisePerformance: FitnessExercisePerformance) {
        self._exercisePerformance = ObservedObject(wrappedValue: exercisePerformance)
    }

    var body: some View {
        if exercisePerformance.exerciseStarted && exercisePerformance.exerciseEnded {
            ZStack {
                AppBackground().ignoresSafeArea()
                VStack(spacing: 10) {
                    TitleText
                    RepSummaryView(screenWidth: screenWidth,
                               totalCorrect: CGFloat(exercisePerformance.totalCorrect),
                               totalIncorrect: CGFloat(exercisePerformance.totalIncorrect),
                               targetCount: exercisePerformance.targetCount)
                    TimeSummaryView(screenWidth: screenWidth,
                                totalTime: CGFloat(exercisePerformance.totalTime),
                                targetTime: exercisePerformance.targetTime)
                    .padding(.top, 10)
                    FeedbackSummaryView(screenWidth: screenWidth,
                                    feedbackText: exercisePerformance.feedbackText,
                                    totalCorrect: exercisePerformance.totalCorrect,
                                    totalCount: exercisePerformance.totalCorrect + exercisePerformance.totalIncorrect)
                    .padding(.top, 10)
                    DoneButton
                }
            }
        }
    }
    
    var TitleText: some View {
        Text("Summary")
            .foregroundColor(.lightOffWhite)
            .font(.system(size: 35, weight: .heavy, design: .default))
            .padding(.horizontal)
            .background(
                Color.Orange.opacity(0.8)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .shadow(radius: 3)
    }
    
    var DoneButton: some View {
        Button(action: {
            exercisePerformance.exerciseStarted = false
            exercisePerformance.exerciseEnded = false
        }) {}
            .buttonStyle(ScaledButtonStyle_OffColorText(text: "Done",
                                                        originColor: .Orange,
                                                        offColor: .lightOffWhite,
                                                        textFont: 30,
                                                        scaleRadius: 0.7,
                                                        animationDuration: 0.2))
    }
}



struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView(exercisePerformance: FitnessExercisePerformance())
    }
}
