//
//  Routine.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 23/7/25.
//

import SwiftUI
import AudioToolbox
import AVFoundation

struct RoutineView: View {
    @EnvironmentObject var theme: AppThemeController
    
    @Binding var selectedDate: Date
    @Binding var selectedCategory: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    
    @State var selectedCategoryId: [UUID] = []
    @State var isOccupied: UUID?
    
    @Environment(\.managedObjectContext) var viewContext
    @State var routineParameter: [RoutineExerciseStorage] = []
    @State var selectedParameter: RoutineExerciseStorage?
    
    @State var showExerciseSelectionSheet: Bool = false
    @State var unlockTrash: Bool = false
    
    @State private var isPressingOnText = false
    @State private var beingPressedOn: Int? = nil
    
    @EnvironmentObject var tabViewController: TabViewController
    @Namespace private var animation
    
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Text(selectedDate.formatted(.dateTime.year().month(.wide).day(.defaultDigits)))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 44)
                        .neumorphicInset(cornerRadius: 22)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .transition(.scale)
                    
                    if !routineParameter.isEmpty && !showExerciseSelectionSheet {
                        Button(action: {
                            if unlockTrash {
                                RoutineExerciseStorage.deleteRoutineParameter(for: selectedDate, in: viewContext)
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
                                }
                                unlockTrash = false
                            } else {
                                unlockTrash = true
                            }
                        }) {
                            Image(systemName: unlockTrash ? "trash.fill" : "trash")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(unlockTrash ? .white : theme.main.text.opacity(0.6))
                                .frame(width: 44, height: 44)
                                .background {
                                    if unlockTrash {
                                        Circle().fill(Color.red)
                                    }
                                }
                                .neumorphicCircle(isPressed: unlockTrash)
                        }
                        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.9))
                        .transition(.scale)
                    }
                    
                    Button(action: {
                        if showExerciseSelectionSheet {
                            try? viewContext.save()
                            selectedCategoryId = []
                            isOccupied = nil
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
                            }
                        }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            showExerciseSelectionSheet.toggle()
                        }
                    }) {
                        Image(systemName: showExerciseSelectionSheet ? "checkmark" : "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(showExerciseSelectionSheet ? .white : theme.main.text)
                            .frame(width: 44, height: 44)
                            .background {
                                if showExerciseSelectionSheet {
                                    Circle().fill(theme.accentGradient)
                                }
                            }
                            .neumorphicCircle(isPressed: showExerciseSelectionSheet)
                    }
                    .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.9))
                    .transition(.scale)
                }
                .padding(.bottom, 8)
                
                if showExerciseSelectionSheet {
                    ExerciseSelectionSheet(selectedDate: selectedDate,
                                           selectedCategory: $selectedCategory,
                                           routineParameter: $routineParameter,
                                           selectedCategoryId: $selectedCategoryId,
                                           isOccupied: $isOccupied)
                        .transition(.move(edge: .trailing))
                } else {
                    currentRoutine
                        .transition(.move(edge: .leading))
                }
            }
            .frame(width: UIScreen.main.bounds.width - 32)
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .neumorphicCard(cornerRadius: 28)
        }
        .onAppear {
            routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
        }
        .onChange(of: selectedDate) {_ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
                isOccupied = nil
                selectedCategoryId = []
            }
        }
    }
    
    var currentRoutine: some View {
        ScrollView(showsIndicators: false) {
            Spacer().frame(height: 12)
            VStack(spacing: 12) {
                if routineParameter.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "figure.run.circle")
                            .font(.system(size: 36))
                            .foregroundColor(theme.main.text.opacity(0.35))
                        Text("No planned exercises today")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.main.text.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .neumorphicInset(cornerRadius: 20)
                    .padding(.horizontal, 6)
                    .transition(.opacity)
                }
                else {
                    ForEach(routineParameter.indices, id: \.self) { index in
                        let parameter = routineParameter[index]
                        CardView(name: parameter.categoryName ?? "Squat",
                                 targetCount: Int(parameter.targetCount),
                                 targetTime: Int(parameter.targetTime),
                                 actionButton: {},
                                 index: index)
                        .padding(.horizontal, 4)
                    }
                }
            }
            Spacer().frame(height: 12)
        }
        .frame(maxHeight: 350)
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: UIScreen.main.bounds.width - 50)
    }
    
    @ViewBuilder
    func CardView(name: String,
                  targetCount: Int,
                  targetTime: Int,
                  width: CGFloat = UIScreen.main.bounds.width - 100,
                  actionButton: @escaping () -> Void = {},
                  index: Int) -> some View {
        let images = FitnessExerciseCategory().imageForExerciseCard(named: name)
        let category = FitnessExerciseCategory().loadCategory(named: name)
    
        HStack(spacing: 12) {
            HStack(spacing: 2) {
                Image("\(images.0)")
                    .resizable()
                    .scaledToFit()
                Image("\(images.1)")
                    .resizable()
                    .scaledToFit()
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(height: 70)
            .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.main.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                explicationSummary(targetCount: targetCount, targetTime: targetTime)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.main.text.opacity(0.3))
                .padding(.trailing, 10)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .neumorphicCard(cornerRadius: 20)
        .scaleEffect(isPressingOnText && beingPressedOn == index ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressingOnText)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                exercisePerformance.targetCount = (targetCount == -1) ? nil : targetCount
                exercisePerformance.targetTime = (targetTime == -1) ? nil : targetTime
                selectedCategory = category
                tabViewController.showTabBar = false
            }
        }
        .onLongPressGesture(minimumDuration: 1.5, pressing: { isPressing in
            isPressingOnText = isPressing
            if isPressing {
                beingPressedOn = index
            }
        } ,perform: {
            if let index = beingPressedOn {
                viewContext.delete(routineParameter[index])
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
                    selectedParameter = nil
                }
                try? viewContext.save()
            }
        })
        .transition(.move(edge: .leading))
    }
    
    @ViewBuilder
    func explicationSummary(targetCount: Int, targetTime: Int) -> some View {
        HStack(spacing: 8) {
            if targetCount != -1 {
                HStack(spacing: 4) {
                    Text("REP")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(theme.accentGradient))
                    
                    Text("\(targetCount)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .neumorphicInset(cornerRadius: 12)
            }
            
            if targetTime != -1 {
                HStack(spacing: 4) {
                    Text("TIME")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(NeumorphicColors.blueGradient))
                    
                    Text("\(targetTime / 60):\(String(format: "%02d", targetTime % 60))")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .neumorphicInset(cornerRadius: 12)
            }
        }
    }
}







struct Routine_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var currentDate = Date()
//        @State var selectedCategory = FitnessExerciseCategory().categories.first
//        RoutineView(selectedDate: $currentDate,
//                    selectedCategory: $selectedCategory, exercisePerformance: FitnessExercisePerformance())
//            .environmentObject(TabViewController())
//            .environmentObject(UserController())
//            .environmentObject(AppThemeController())
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
    
    static var previews: some View {
        HomeView()
            .environmentObject(TabViewController())
            .environmentObject(AppThemeController())
            .environmentObject(UserController())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
