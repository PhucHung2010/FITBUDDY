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
                // tool bar
                HStack {
                    Text(selectedDate.formatted(.dateTime.year().month(.wide).day(.defaultDigits)))
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(theme.main.text)
                        .padding(5)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 40)
                        .background(BlurRoundedBackground(cornerRadius: 20, shadowRadius: 3, style: theme.main.ultraThinMaterial))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .transition(.scale)
                    
                    if !routineParameter.isEmpty && !showExerciseSelectionSheet {
                        Button(action: {
                            if unlockTrash {
                                RoutineExerciseStorage.deleteRoutineParameter(for: selectedDate, in: viewContext)
                                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                    routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
                                }
                                unlockTrash = false
                            } else {
                                unlockTrash = true
                            }
                        }) {
                            Image(systemName: unlockTrash ? "trash.circle.fill" : "trash.slash.circle.fill")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(.Orange)
                                .frame(height: 40)
                                .background {
                                    BlurView(style: theme.main.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                        }
                        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                        .transition(.scale)
                    }
                    
                    Button(action: {
                        if showExerciseSelectionSheet {
                            try? viewContext.save()
                            selectedCategoryId = []
                            isOccupied = nil
                            withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
                            }
                        }
                        withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                            showExerciseSelectionSheet.toggle()
                        }
                    }) {
                        Image(systemName: showExerciseSelectionSheet ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.Orange)
                            .frame(height: 40)
                            .background {
                                BlurView(style: theme.main.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                    }
                    .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                    .transition(.scale)
                }
                
                
            
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
            .frame(width: UIScreen.main.bounds.width - 50)
            .padding(5)
            .mask(RoundedRectangle(cornerRadius: 25))
            .background(BlurRoundedBackground(cornerRadius: 25, style: theme.main.ultraThinMaterial))
        }
        .onAppear {
            routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
//            RoutineExerciseStorage.deleteRoutineExerciseStorage(for: selectedDate, in: viewContext)
        }
        .onChange(of: selectedDate) {_ in
            withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
                isOccupied = nil
                selectedCategoryId = []
            }
        }
    }
    
    
    
    var currentRoutine: some View {
        ScrollView(showsIndicators: false) {
            Spacer().frame(height: 20)
            VStack {
                if routineParameter.isEmpty {
                    Text("There's no planned exercise")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.main.text)
                        .padding(5)
                        .background(BlurRoundedBackground(cornerRadius: 20, style: theme.main.ultraThinMaterial))
                        .padding(.horizontal)
                        .transition(.move(edge: .leading))
                }
                else {
                    ForEach(routineParameter.indices, id: \.self) { index in
                        let parameter = routineParameter[index]
                        CardView(name: parameter.categoryName ?? "Squat",
                                 targetCount: Int(parameter.targetCount),
                                 targetTime: Int(parameter.targetTime),
                                 actionButton: {},
                                 index: index)
                        .padding(.horizontal)
                    }
                }
            }
            Spacer().frame(height: 20)
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
    
        BlurView(style: theme.main.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
//            .shadow(color: Color.white.opacity(0.4), radius: 10, x: -3, y: -3)
//            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 3, y: 3)
            .shadow(radius: 4)
            .overlay {
                HStack {
                    HStack(spacing: 2) {
                        Image("\(images.0)")
                            .resizable()
                            .scaledToFit()
                        Image("\(images.1)")
                            .resizable()
                            .scaledToFit()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(height: 75)
                    .padding(.leading, 2.5)
                    .shadow(radius: 2)
                    
                    VStack {
                        Text(name)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(.linearGradient(colors: [.Orange, .Orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .multilineTextAlignment(.center)
                            .padding(.trailing, 5)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .shadow(radius: 2)
                        
                        explicationSummary(targetCount: targetCount, targetTime: targetTime)
                    }
                    .padding(.bottom, 3)
                }
            }
            .frame(height: 80)
            .scaleEffect(isPressingOnText && beingPressedOn == index ? 0.5 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 1), value: isPressingOnText)
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
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
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
        HStack {
            if targetCount != -1 {
                HStack {
                    Text("Rep")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(2)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.yellow)
                                .frame(height: 20)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shadow(radius: 1)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                    Text("\(targetCount)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(theme.main.text)
                        .padding(.trailing, 10)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                }
                .frame(height: 20)
                .background(
                    BlurView(style: theme.main.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .shadow(radius: 2)
                )
            } else {
                Spacer().frame(maxWidth: .infinity)
            }
            
            if targetTime != -1 {
                HStack {
                    Text("Time")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(2)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.cyan.opacity(0.8))
                                .frame(height: 20)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shadow(radius: 1)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                    Text("\(targetTime / 60):\(targetTime % 60)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(theme.main.text)
                        .padding(.trailing, 10)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                }
                .frame(height: 20)
                .background(
                    BlurView(style: theme.main.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .shadow(radius: 2)
                )
            } else {
                Spacer().frame(maxWidth: .infinity)
            }
        }
        .padding(.trailing, 5)
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
