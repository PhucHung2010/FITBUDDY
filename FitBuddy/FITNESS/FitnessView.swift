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
    @State private var searchTerm = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var showAbstract = false
    
    var filteredExercise: [Category] {
        guard !searchTerm.isEmpty else { return exerciseCategory.categories }
        return exerciseCategory.categories.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
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
    
    @State private var selectedCategory: Category?
    @Namespace private var animation

    var body: some View {
        ZStack {
            if selectedCategory == nil {
                ScrollView(showsIndicators: false) {
                    Spacer().frame(height: 76)
                    
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

                    Spacer().frame(height: 100)
                }
                .animation(.spring(response: 0.5, dampingFraction: 1), value: searchTerm)
            
                toolbar
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

    // MARK: - Search Toolbar (Neumorphic App Bar)
    var toolbar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        showAbstract.toggle()
                    }
                }) {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(showAbstract ? .white : theme.main.text)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .background {
                            if showAbstract {
                                Circle().fill(theme.accentGradient)
                            }
                        }
                        .neumorphicCircle(isPressed: showAbstract)
                }
                .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.9))
                        
                // Sunken Search Input Well
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(theme.main.text.opacity(0.45))
                        .font(.system(size: 15, weight: .medium))
                    
                    TextField("", text: $searchTerm, prompt: Text("Search Exercises...").foregroundColor(theme.main.text.opacity(0.45)))
                        .focused($isTextFieldFocused)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(theme.main.text)
                        .onChange(of: isTextFieldFocused) { newValue in
                            if newValue {
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
                    } else {
                        NeumorphicIndicatorDots(dotSize: 4, spacing: 3)
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .neumorphicInset(cornerRadius: 22)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .neumorphicCard(cornerRadius: 26)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            if showAbstract {
                Abstract()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    @ViewBuilder
    func Abstract() -> some View {
        if showAbstract {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(sortedExerciseByName, id: \.name) { category in
                            Button(action: {
                                if searchTerm == category.name {
                                    searchTerm = ""
                                } else {
                                    searchTerm = category.name
                                }
                                showAbstract = false
                                isTextFieldFocused = false
                            }) {
                                HStack {
                                    Text(category.name)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(
                                            searchTerm == category.name
                                            ? .white : theme.main.text
                                        )
                                    Spacer()
                                    if searchTerm == category.name {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .frame(height: 40)
                                .background(
                                    searchTerm == category.name ? AnyView(theme.accentGradient) : AnyView(Color.clear)
                                )
                            }
                            .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
                            .id(category.name)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .frame(width: 230, height: 300)
                .neumorphicCard(cornerRadius: 22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .onAppear {
                    withAnimation {
                        proxy.scrollTo(searchTerm, anchor: .bottom)
                    }
                }
            }
            .transition(.scale.combined(with: .opacity))
        }
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
                    isTextFieldFocused = false
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
