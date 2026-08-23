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
        VStack(spacing: 12) {
            // Sunken Search Input Well
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(theme.main.text.opacity(0.45))
                    .font(.system(size: 15, weight: .medium))
                
                TextField("", text: $searchTerm, prompt: Text("Search Exercises...").foregroundColor(theme.main.text.opacity(0.45)))
                    .focused($isTextFieldFocused)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(theme.main.text)
                    .onChange(of: isTextFieldFocused) { isFocused in
                        if isFocused {
                            tabViewController.showTabBar = false
                        } else {
                            if selectedCategory == nil {
                                tabViewController.showTabBar = true
                            }
                        }
                    }
                
                if !searchTerm.isEmpty {
                    Button(action: { searchTerm = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(theme.main.text.opacity(0.4))
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .neumorphicInset(cornerRadius: 22)
            .padding(.horizontal, 4)
            .padding(.top, 6)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(groupedExercise, id: \.group) { (group, exercises) in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(theme.accentGradient)
                                    .frame(width: 4, height: 16)
                                Text(group.displayName)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.main.text)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .neumorphicCard(cornerRadius: 14)
                            
                            ForEach(exercises, id: \.id) { category in
                                VStack(spacing: 8) {
                                    CardView(category: category)
                                        .transition(.offset(x: -500))

                                    if isOccupied == category.id {
                                        VStack(spacing: 10) {
                                            HStack(spacing: 10) {
                                                RepPickerView(category: category, exercisePerformance: exercisePerformance)
                                                TimePickerView(category: category, exercisePerformance: exercisePerformance)
                                            }

                                            Button(action: {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
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
                                                HStack(spacing: 8) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 18, weight: .bold))
                                                    Text("Save Exercise")
                                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                                }
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 44)
                                                .background(
                                                    Capsule()
                                                        .fill(NeumorphicColors.greenGradient)
                                                        .shadow(color: Color.black.opacity(0.18), radius: 5, y: 2)
                                                )
                                            }
                                            .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.95))
                                        }
                                        .padding(10)
                                        .neumorphicCard(cornerRadius: 20)
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                Spacer().frame(height: 80)
            }
        }
        .frame(height: 500)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: searchTerm)
    }
    
    @ViewBuilder
    func CardView(category: Category) -> some View {
        let images = FitnessExerciseCategory().imageForExerciseCard(named: category.name)
        let isSelected = selectedCategoryId.contains(category.id)
        
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
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
                } else {
                    isOccupied = category.id
                }
            }
        }) {
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(theme.main.text)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(NeumorphicColors.dotGreen)
                        .padding(.trailing, 10)
                } else if isOccupied == category.id {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.25))
                        .padding(.trailing, 10)
                } else {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(theme.main.text.opacity(0.4))
                        .padding(.trailing, 10)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .neumorphicCard(cornerRadius: 20, accentGlow: isSelected ? NeumorphicColors.dotGreen.opacity(0.6) : nil)
            .frame(height: 78)
        }
        .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
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
