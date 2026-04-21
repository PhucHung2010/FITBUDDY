//
//  TrainingView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 03/06/2025.
//

import SwiftUI
import AVFoundation
import MediaPlayer


struct ExerciseParameterSettingView: View {
    @EnvironmentObject var theme: AppThemeController
    @Binding var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    @EnvironmentObject var tabViewController: TabViewController
    @State var showInstruction: Bool = false
    @State var showAdjustment: Bool = false
    @State var showHistorySummary: Bool = false
    
    
    init(category: Binding<Category?>,
         exercisePerformance: FitnessExercisePerformance) {
        self._category = category
        self.exercisePerformance = exercisePerformance
    }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                category = nil
                                tabViewController.showTabBar = true
                            }
                            showAdjustment = false
                            showHistorySummary = false
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundColor(.Orange)
                                Text("Library")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundColor(.Orange)
                            }
                            .padding(2)
                            .background (BlurRoundedBackground(cornerRadius: 30))
                            .shadow(radius: 2)
                        }
                        .padding(.leading)
                        .padding(.top)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    
                    
                    
                    if let category = category {
                        AppHeadingView(title: category.name)
                    }
                    
                    
                    if let category = category {
                        VStack(spacing: 10) {
                           PreviewImage(category: category)
                        }
                        .padding(5)
                        .mask(RoundedRectangle(cornerRadius: 25))
                        .background (BlurRoundedBackground(cornerRadius: 25))
                    }
                    
                    VStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                showInstruction.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "text.book.closed.fill")
                                Text("INSTRUCTION")
                            }
                            .font(.system(size: 25, weight: .black))
                            .foregroundColor(showInstruction ? Color.offWhite : theme.main.accent)
                            .shadow(radius: 2)
                            .frame(width: UIScreen.main.bounds.width - 30, height: 40)
                            .background {
                                if (showInstruction) {
                                    theme.main.accent
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .shadow(radius: 3)
                                } else {
                                    BlurView(style: theme.main.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .shadow(radius: 6)
                                }
                            }
                        }
                        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                        
                        if showInstruction {
                            if let category = category {
                                InstructionView(category: category)
                                    .padding(.bottom)
                            }
                        }
                    }
                    .mask(RoundedRectangle(cornerRadius: 20))
                    .background {
                        BlurRoundedBackground(cornerRadius: 20)
                    }
                    
                    
                    VStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                showHistorySummary.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("PROCESS")
                            }
                            .font(.system(size: 25, weight: .black))
                            .foregroundColor(showHistorySummary ? .lightOffWhite : theme.main.accent)
                            .shadow(radius: 2)
                            .frame(width: UIScreen.main.bounds.width - 30, height: 40)
                            .background {
                                if (showHistorySummary) {
                                    theme.main.accent
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .shadow(radius: 3)
                                } else {
                                    BlurView(style: theme.main.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .shadow(radius: 6)
                                }
                            }
                        }
                        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))

                        if showHistorySummary {
                            if let category = category {
                                HistorySummary(category: category)
                            }
                        }
                    }
                    .mask(RoundedRectangle(cornerRadius: 20))
                    .background {
                        BlurRoundedBackground(cornerRadius: 20)
                    }
                    
                    
                    VStack {
                        Button(action: {
                            if showAdjustment {
                                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                    if let category = category?.exerciseAdjustment {
                                        exercisePerformance.controller = category
                                        exercisePerformance.exerciseStatus = .traning
                                    }
                                }
                            } else {
                                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                    showAdjustment.toggle()
                                }
                            }
                        }) {
                            HStack() {
                                Image(systemName: "dumbbell.fill")
                                Text("START")
                            }
                            .font(.system(size: 25, weight: .black))
                            .foregroundColor(Color.lightOffWhite)
                            .shadow(radius: 2)
                            .frame(width: UIScreen.main.bounds.width - 30, height: 40)
                            .background {
                                if showAdjustment {
                                    Color.green
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .shadow(radius: 3)
                                } else {
                                    theme.main.accent
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .shadow(radius: 3)
                                }
                            }
                        }
                        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                        
                        if showAdjustment {
                            AdjustmentView(category: $category, exercisePerformance: exercisePerformance)
                                .padding(.bottom)
                        }
                    }
                    .mask(RoundedRectangle(cornerRadius: 20))
                    .background {
                        BlurRoundedBackground(cornerRadius: 20)
                    }
                    
                    Spacer().frame(height: 200)
                }
            }
        }
        .background {
            AppBackground()
        }
    }
}

struct TrainingView_CustomePreviews_Previews: PreviewProvider {
    static var previews: some View {
        @State var category = FitnessExerciseCategory().categories.first
        ExerciseParameterSettingView(category: $category,
                                     exercisePerformance: FitnessExercisePerformance())
            .environmentObject(TabViewController())
            .environmentObject(AppThemeController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

