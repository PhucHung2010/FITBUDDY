//
//  ExerciseSelectionSheet.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 5/8/25.
//

import SwiftUI

struct ExerciseSelectionSheet: View {
    @EnvironmentObject var theme: AppThemeController
    
    let selectedDate: Date
    @Binding var selectedCategory: Category?
    
    @ObservedObject var exercisePerformance: FitnessExercisePerformance = FitnessExercisePerformance()
    
    @Environment(\.managedObjectContext) var viewContext
    @Binding var routineParameter: [RoutineExerciseStorage]
    
    @State var exerciseCategory = FitnessExerciseCategory()
    
    @Binding var selectedCategoryId: [UUID]
    @Binding var isOccupied: UUID?
    
    @State var searchTerm = ""
    
    var filteredExercise: [Category] {
        guard !searchTerm.isEmpty else { return exerciseCategory.categories }

        return exerciseCategory.categories.filter { $0.name.localizedCaseInsensitiveContains (searchTerm) }
    }
    
    var sortedExerciseByName: [Category] {
        exerciseCategory.categories.sorted {
            $0.name.prefix(1).localizedCaseInsensitiveCompare($1.name.prefix(1)) == .orderedAscending
        }
    }
    
    var groupedExercise: [(group: MuscleGroup, exercises: [Category])] {
        let grouped = Dictionary(grouping: filteredExercise) { $0.muscleGroup }
        return grouped
            .map { (key: MuscleGroup, value: [Category]) in
                (group: key, exercises: value.sorted { $0.name < $1.name })
            }
            .sorted { $0.group.displayName < $1.group.displayName }
    }
    
    @FocusState private var isTextFieldFocused: Bool
    @EnvironmentObject var tabViewController: TabViewController
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 10)
            
            TextField("", text: $searchTerm, prompt: Text("Search Exercises").foregroundColor(theme.main.text))
                .modifier(customViewModifier(startColor: .offWhite, endColor: .darkOffWhite2, textColor: theme.main.accent, roundedCornes: 20))
                .focused($isTextFieldFocused)
                .onChange(of: isTextFieldFocused) { isFocused in
                    if isFocused {
                        tabViewController.showTabBar = false
                    } else {
                        if selectedCategory == nil {
                            tabViewController.showTabBar = true
                        }
                    }
                }
                .padding(.horizontal)
            
            
            ScrollView(showsIndicators: false) {
                Spacer().frame(height: 10)
                
//                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1)) {
                VStack(spacing: 20) {
                    ForEach(groupedExercise, id: \.group) { (group, exercises) in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.displayName)
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundColor(theme.main.accent)
                                .padding(.horizontal)
                                .background {
                                    BlurRoundedBackground(cornerRadius: 20, style: theme.main.ultraThinMaterial)
                                }
                            
                            ForEach(exercises, id: \.id) {category in
                                VStack {
                                    CardView(category: category)
                                        .transition(.offset(x: -500))

                                    if isOccupied == category.id{
                                        VStack {
                                            HStack {
                                                RepPickerView(category: category, exercisePerformance: exercisePerformance)
                                                TimePickerView(category: category, exercisePerformance: exercisePerformance)
                                            }

                                            Button(action: {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                                    isOccupied = nil
                                                    selectedCategoryId.append(category.id)
                                                }
                                                let obj = RoutineExerciseStorage(context: viewContext)
                                                obj.id = category.id
                                                obj.categoryName = category.name
                                                obj.plannedDate = selectedDate.startOfDay
                                                obj.targetCount = Int32(exercisePerformance.targetCount ?? -1)
                                                obj.targetTime = Int32(exercisePerformance.targetTime ?? -1)

                                                try? viewContext.save()
                                                routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
                                            }) {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 25, weight: .heavy))
                                                    .foregroundColor(theme.main.mainColor)
                                                    .shadow(radius: 3)
                                                    .frame(height: 40)
                                                    .frame(maxWidth: .infinity)
                                                    .background {
                                                        theme.main.accent
                                                            .clipShape(RoundedRectangle(cornerRadius: 40))
                                                            .shadow(radius: 6)
                                                    }
                                            }
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .overlay {
                                    if selectedCategoryId.contains(category.id) || isOccupied == category.id{
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(theme.main.accent, lineWidth: 5)
                                            .transition(.opacity)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer().frame(height: 100)
            }
        }
        .frame(height: 500)
        .animation(.spring(response: 0.5, dampingFraction: 1), value: searchTerm)
    }
    
    
    
    @ViewBuilder
    func CardView(category: Category) -> some View {
        let images = FitnessExerciseCategory().imageForExerciseCard(named: category.name)
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                if selectedCategoryId.contains(category.id) {
                    selectedCategoryId.removeAll { $0 == category.id }
                    if let obj = routineParameter.first(where: { $0.id == category.id }) {
                        viewContext.delete(obj)
                        try? viewContext.save()
                        routineParameter = RoutineExerciseStorage.loadRoutineParameter(for: selectedDate, in: viewContext)
                    }
                    isOccupied = nil
                } else if isOccupied == category.id {
                    isOccupied = nil
                }
                else {
                    isOccupied = category.id
                }
            }
        }) {
            BlurView(style: theme.main.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15))
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
                            Text(category.name)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundStyle(.linearGradient(colors: [theme.main.accent, theme.main.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .multilineTextAlignment(.center)
                                .padding(.trailing, 5)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                                .shadow(radius: 2)
                            Spacer().frame(maxWidth: .infinity).frame(height: 0)
                        }
//                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.bottom, 3)
                    }
                }
                .frame(height: 80)
        }
        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.3))
    }
}


struct ExerciseSelectionSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var currentDate = Date()
//        @State var selectedCategory = FitnessExerciseCategory().categories.first
//        RoutineView(selectedDate: $currentDate,
//                    selectedCategory: $selectedCategory, exercisePerformance: FitnessExercisePerformance())
//            .environmentObject(TabViewController())
//            .environmentObject(UserController())
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
    
    static var previews: some View {
        HomeView()
            .environmentObject(TabViewController())
            .environmentObject(AppThemeController())
            .environmentObject(UserController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
