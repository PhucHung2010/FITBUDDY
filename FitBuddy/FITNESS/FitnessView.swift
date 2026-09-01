//
//  FitnessView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//

import SwiftUI

struct FitnessView: View {
    var body: some View {
        FitnessGallery()
    }
}

struct FitnessGallery: View {
    @EnvironmentObject var theme: AppThemeController
    @EnvironmentObject var tabViewController: TabViewController
    
    @ObservedObject var exercisePerformance = FitnessExercisePerformance()
    @State var exerciseCategory = FitnessExerciseCategory()
    var groupedExercise: [(group: MuscleGroup, exercises: [Category])] {
        let grouped = Dictionary(grouping: exerciseCategory.categories) { $0.muscleGroup }
        return grouped
            .map { (key: MuscleGroup, value: [Category]) in
                (group: key, exercises: value.sorted { $0.name < $1.name })
            }
            .sorted { $0.group.displayName < $1.group.displayName }
    }
    
    @State private var selectedCategory: Category?
    @Namespace private var animation

    var body: some View {
        ZStack {
            if selectedCategory == nil {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Clean Header
                        headerView
                        
                        LazyVStack(spacing: 24) {
                            ForEach(groupedExercise, id: \.group) { (group, exercises) in
                                VStack(spacing: 12) {
                                    // Category Header Pill
                                    HStack(spacing: 10) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(theme.accentGradient)
                                            .frame(width: 4, height: 18)
                                        
                                        Text(group.displayName)
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(theme.main.text)
                                        
                                        Spacer()
                                        
                                        Text("\(exercises.count) exercises")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(theme.main.text.opacity(0.5))
                                        
                                        NeumorphicIndicatorDots(dotSize: 5, spacing: 4)
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .neumorphicCard(cornerRadius: 18)
                                    
                                    ForEach(exercises, id: \.id) { category in
                                        CardView(category: category)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }

                    Spacer().frame(height: 100)
                }
            } else if let selected = selectedCategory {
                TrainingView(category: $selectedCategory,
                             exercisePerformance: exercisePerformance)
                .transition(.scale)
                .matchedGeometryEffect(id: selected.id, in: animation)
            }
        }
        .background {
            AppBackground().ignoresSafeArea()
        }
    }

    // MARK: - Header
    var headerView: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(theme.accentGradient)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
            }
            .neumorphicCircle()
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Exercises")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(theme.main.text)
                
                Text("AI Pose-Guided Workouts")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(theme.main.text.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    // MARK: - Exercise Card View (Extruded Neumorphic Card)
    @ViewBuilder
    func CardView(category: Category) -> some View {
        if selectedCategory?.id == category.id {
            RoundedRectangle(cornerRadius: 24)
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .foregroundColor(.clear)
        } else {
            Button(action: {
                withAnimation(.easeInOut) {
                    selectedCategory = category
                    tabViewController.showTabBar = false
                }
            }) {
                HStack(spacing: 14) {
                    if let image = category.images.first {
                        HStack(spacing: 4) {
                            Image("\(image.0)")
                                .resizable()
                                .scaledToFit()
                            Image("\(image.1)")
                                .resizable()
                                .scaledToFit()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .frame(height: 116)
                        .padding(.leading, 10)
                        .padding(.vertical, 8)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(category.name)
                                .font(.system(size: 21, weight: .heavy, design: .rounded))
                                .foregroundColor(theme.main.text)
                                .multilineTextAlignment(.trailing)
                                .minimumScaleFactor(0.6)
                            
                            NeumorphicIndicatorDots(dotSize: 4, spacing: 3)
                        }
                        .padding(.trailing, 18)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .neumorphicCard(cornerRadius: 24)
                .matchedGeometryEffect(id: category.id, in: animation)
            }
            .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
            .padding(.bottom, 4)
        }
    }
}

struct fitnessView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
            .environmentObject(TabViewController())
            .environmentObject(UserController())
            .environmentObject(AppThemeController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
