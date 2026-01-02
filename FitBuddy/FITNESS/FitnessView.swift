//
//  fitnessView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//

import SwiftUI

struct FitnessView: View {
    var body: some View {
//        ZStack {
//            AppBackground()
            FitnessGallery()
//        }
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
    
    @State private var selectedCategory: Category?
    @Namespace private var animation

    var body: some View {
        ZStack {
            if selectedCategory == nil {
                
                    ScrollView(showsIndicators: false) {
                        Spacer().frame(height: 60)
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 1)) {
                            ForEach(groupedExercise, id: \.group) { (group, exercises) in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(group.displayName)
                                        .font(.system(size: 25, weight: .bold, design: .rounded))
                                        .foregroundColor(.Orange)
                                        .padding(.horizontal)
                                        .background {
                                            BlurView(style: theme.main.ultraThinMaterial)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .shadow(radius: 4)
                                        }
                                    
                                    ForEach(exercises, id: \.id) { category in
                                        CardView(category: category)
                                    }
                                    
                                }
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


    
    
    var toolbar: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                        showAbstract.toggle()
                    }
                }) {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(theme.main.text)
                        .font(.system(size: 25, weight: .semibold))
                }
                .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                        
                TextField("", text: $searchTerm, prompt: Text("Search Exercises").foregroundColor(theme.main.text))
                    .focused($isTextFieldFocused)
                    .onChange(of: isTextFieldFocused) { newValue in
                        if newValue {
                            tabViewController.showTabBar = false
                        } else {
                            if selectedCategory == nil {
                                tabViewController.showTabBar = true
                            }
                        }
                    }

            }
            .modifier(customViewModifier(startColor: .offWhite, endColor: .darkOffWhite2, textColor: .Orange, roundedCornes: 20))
            .padding(.horizontal)
            
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
                                VStack {
                                    Divider()
                                    Text(category.name)
                                        .font(.system(size: 20, weight: .regular))
                                        .foregroundColor(
                                            searchTerm == category.name
                                            ? .white : theme.main.text
                                        )
                                        .frame(maxWidth: .infinity, alignment:
                                                .leading)
                                        .padding(.horizontal, 7)
                                        .frame(width: 200, height: 30)
                                        .minimumScaleFactor(0.2)
                                    Divider()
                                }
                                .background(
                                    searchTerm == category.name ? Color.Orange : Color.white.opacity(0.00001)
                                )
                            }
                            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                            .id(category.name)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .frame(width: 200, height: 320)
                .background (BlurRoundedBackground(cornerRadius: 10, style: .systemUltraThinMaterialDark))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .onAppear {
                    withAnimation {
                        proxy.scrollTo(searchTerm, anchor: .bottom)
                    }
                }
            }
            .transition(.move(edge: .leading))
        }
    }
    
    @ViewBuilder
    func CardView(category: Category) -> some View {
        if selectedCategory?.id == category.id {
            RoundedRectangle(cornerRadius: 30).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width).foregroundColor(.white.opacity(0.0000001))
        }
        else {
            Button(action: {
                withAnimation(.easeInOut) {
                    selectedCategory = category
                    isTextFieldFocused = false
                    tabViewController.showTabBar = false
                }
            }) {
                BlurView(style: theme.main.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.4),
                            radius: 4,
                            x: 3, y: 3)
                    .shadow(color: .black.opacity(0.2),
                            radius: 2,
                            x: -1, y: -1)
                    .overlay {
                        if let image = category.images.first {
                            HStack {
                                HStack(spacing: 4) {
                                    Image("\(image.0)")
                                        .resizable()
                                        .scaledToFit()
                                    Image("\(image.1)")
                                        .resizable()
                                        .scaledToFit()
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(height: 140)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 5)
                                
                                Text(category.name)
                                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.linearGradient(colors: [.Orange, .Orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .multilineTextAlignment(.center)
                                    .frame(width: (UIScreen.main.bounds.width - 30) / 2.5)
                                    .minimumScaleFactor(0.5)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 30, height: 150)
                    .matchedGeometryEffect(id: category.id, in: animation)
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.3))
            .padding(.bottom, 10)
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
