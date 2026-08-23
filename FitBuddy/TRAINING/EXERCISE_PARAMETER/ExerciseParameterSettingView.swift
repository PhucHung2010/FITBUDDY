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
            AppBackground().ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header Bar
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                category = nil
                                tabViewController.showTabBar = true
                            }
                            showAdjustment = false
                            showHistorySummary = false
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15, weight: .bold))
                                Text("Library")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(theme.main.text)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .neumorphicPill()
                        }
                        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.9))
                        
                        Spacer()
                        
                        NeumorphicIndicatorDots(dotSize: 5, spacing: 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    if let category = category {
                        VStack(spacing: 10) {
                            PreviewImage(category: category)
                        }
                        .padding(8)
                        .neumorphicCard(cornerRadius: 26)
                        .padding(.horizontal, 16)
                    }
                    
                    // INSTRUCTION Section Card
                    VStack(spacing: 10) {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                showInstruction.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "text.book.closed.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text("INSTRUCTION")
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                                Spacer()
                                Image(systemName: showInstruction ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(showInstruction ? .white : theme.main.text)
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                            .background {
                                if showInstruction {
                                    RoundedRectangle(cornerRadius: 18).fill(NeumorphicColors.coralGradient)
                                }
                            }
                        }
                        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
                        
                        if showInstruction {
                            if let category = category {
                                InstructionView(category: category)
                                    .padding(.bottom, 8)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                    .padding(8)
                    .neumorphicCard(cornerRadius: 24)
                    .padding(.horizontal, 16)
                    
                    // PROGRESS Section Card
                    VStack(spacing: 10) {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                showHistorySummary.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 16, weight: .bold))
                                Text("PROGRESS")
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                                Spacer()
                                Image(systemName: showHistorySummary ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(showHistorySummary ? .white : theme.main.text)
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                            .background {
                                if showHistorySummary {
                                    RoundedRectangle(cornerRadius: 18).fill(NeumorphicColors.blueGradient)
                                }
                            }
                        }
                        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))

                        if showHistorySummary {
                            if let category = category {
                                HistorySummary(category: category)
                                    .padding(.bottom, 8)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                    .padding(8)
                    .neumorphicCard(cornerRadius: 24)
                    .padding(.horizontal, 16)
                    
                    // START / PARAMETERS Card
                    VStack(spacing: 10) {
                        Button(action: {
                            if showAdjustment {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    if let category = category?.exerciseAdjustment {
                                        exercisePerformance.controller = category
                                        exercisePerformance.exerciseStatus = .traning
                                    }
                                }
                            } else {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    showAdjustment.toggle()
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showAdjustment ? "play.circle.fill" : "slider.horizontal.3")
                                    .font(.system(size: 18, weight: .bold))
                                Text(showAdjustment ? "START WORKOUT" : "CONFIGURE & START")
                                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                Capsule()
                                    .fill(showAdjustment ? NeumorphicColors.greenGradient : NeumorphicColors.coralGradient)
                                    .shadow(color: Color.black.opacity(0.18), radius: 5, y: 2)
                            )
                        }
                        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
                        
                        if showAdjustment {
                            AdjustmentView(category: $category, exercisePerformance: exercisePerformance)
                                .padding(.bottom, 8)
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding(8)
                    .neumorphicCard(cornerRadius: 24)
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 120)
                }
            }
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

