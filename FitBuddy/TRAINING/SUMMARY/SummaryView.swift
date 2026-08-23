//
//  SummaryView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 26/06/2025.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var theme: AppThemeController
    let category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    let screenWidth = UIScreen.main.bounds.width - 40
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            
            VStack(spacing: 20) {

                    RepSummaryView(screenWidth: screenWidth,
                               totalCorrect: CGFloat(exercisePerformance.totalCorrect),
                               totalIncorrect: CGFloat(exercisePerformance.totalIncorrect),
                               targetCount: exercisePerformance.targetCount)
                    TimeSummaryView(screenWidth: screenWidth,
                                totalTime: CGFloat(exercisePerformance.totalTime),
                                targetTime: exercisePerformance.targetTime)
                    FeedbackSummaryView(screenWidth: screenWidth,
                                    feedbackText: exercisePerformance.feedbackText,
                                    totalCorrect: exercisePerformance.totalCorrect,
                                    totalCount: exercisePerformance.totalCorrect + exercisePerformance.totalIncorrect)
                    DoneButton
                
            }
        }
        .onAppear {
            _ = {
                let obj = SummaryExerciseParameterStorage(context: viewContext)
                obj.dateAdded = Date()
                obj.categoryName = category?.name
                
                obj.totalCorrect = Int32(exercisePerformance.totalCorrect)
                obj.totalIncorrect = Int32(exercisePerformance.totalIncorrect)
                obj.targetCount = Int32(exercisePerformance.targetCount ?? -1)
                
                obj.totalTime = Int32(exercisePerformance.totalTime)
                obj.targetTime = Int32(exercisePerformance.targetTime ?? -1)
                
                obj.feedbackText = SummaryExerciseParameterStorage.encodeFeedbackStrings(exercisePerformance.feedbackText ?? [""])
                
                
                return obj
            }()
            try? viewContext.save()
        }
    }
    

    var DoneButton: some View {
        Button(action: {
            exercisePerformance.reinitialize()
        }) {}
            .buttonStyle(ScaledButtonStyle_OffColorText(text: "Done",
                                                        originColor: .Orange,
                                                        offColor: theme.main.mainColor,
                                                        textFont: 30,
                                                        scaleRadius: 0.7,
                                                        animationDuration: 0.2))
    }
}



struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        @State var category = FitnessExerciseCategory().categories.first
        SummaryView(category: category, exercisePerformance: FitnessExercisePerformance())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppThemeController())
    }
}
