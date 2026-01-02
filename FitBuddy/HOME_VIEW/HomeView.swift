//
//  HomeView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 03/06/2025.
//

import SwiftUI
import AudioToolbox

struct HomeView: View {
    @EnvironmentObject var theme: AppThemeController
    @State var selectedDate = Date.now.startOfDay
    @State var selectedCategory: Category?
    @StateObject var exercisePerformance: FitnessExercisePerformance = FitnessExercisePerformance()
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            if selectedCategory == nil {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        AppHeadingView(title: "FitBuddy")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30)
                        CalendarView(selectedDate: $selectedDate)
                        RoutineView(selectedDate: $selectedDate,
                                    selectedCategory: $selectedCategory,
                                    exercisePerformance: exercisePerformance)
                        .padding(.bottom, 20)
                        ArchiveBox()
                        
                        Spacer().frame(height: 100)
                    }
                }
                .onAppear {
                    exercisePerformance.keepAvailable = true
                }
            }
            else if selectedCategory != nil {
                TrainingView(category: $selectedCategory,
                             exercisePerformance: exercisePerformance)
                    .transition(.move(edge: .trailing))
            }
        }
        .background {
            AppBackground()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TabViewController())
            .environmentObject(AppThemeController())
            
            .environmentObject(UserController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
