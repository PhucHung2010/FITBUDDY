//
//  fitnessView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 02/06/2025.
//

import SwiftUI

struct FitnessView: View {
    var body: some View {
        ZStack {
            AppBackground()
            FitnessGallery()
        }
    }
}

struct FitnessGallery: View {
    @EnvironmentObject var wideViewController: WideViewController
    
    @ObservedObject var exercisePerformance = FitnessExercisePerformance()
    let exerciseCategory = ExerciseCategory()
    @State private var searchTerm = ""
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
    
    @State private var selectedCategory: Category?
    @Namespace private var animation

    var body: some View {
        ZStack {
            ZStack {
                ScrollView {
                    Spacer().frame(height: 100)
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 1)) {
                        ForEach(filteredExercise, id: \.id) { category in
                            CardView(category: category)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    Spacer().frame(height: 100)
                }

                VStack {
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                showAbstract.toggle()
                            }
                        }) {
                            Image(systemName: "dumbbell.fill")
                                .foregroundColor(.darkGray)
                                .font(.system(size: 25, weight: .semibold))
                        }
                        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                                
                        TextField("Search Exercises", text: $searchTerm)
                    }
                    .modifier(customViewModifier(startColor: .offWhite, endColor: .darkOffWhite2, textColor: .Orange, roundedCornes: 20))
                    .padding(.horizontal)
                    
                    if showAbstract {
                        Abstract()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.7), value: searchTerm)
            
            if let selected = selectedCategory {
                TrainingView(category: $selectedCategory,
                             exercisePerformance: exercisePerformance)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                    .matchedGeometryEffect(id: selected.id, in: animation)
            }
        }
    }
    
    
    @ViewBuilder
    func Abstract() -> some View {
        if showAbstract {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(sortedExerciseByName, id: \.name) { category in
                            Button(action: {
                                if searchTerm == category.name {
                                    searchTerm = ""
                                } else {
                                    searchTerm = category.name
                                }
                                showAbstract = false
                            }) {
                                VStack {
                                    Divider()
                                    Text(category.name)
                                        .font(.system(size: 20, weight: .regular))
                                        .foregroundColor(
                                            searchTerm == category.name
                                            ? .white : .black
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
                .background (
                    BlurView(style: .systemMaterialLight)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                )
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
            RoundedRectangle(cornerRadius: 0).fill(Color.clear)
        } else {
            Button(action: {
                withAnimation(.easeOut(duration: 0.3)) {
                    selectedCategory = category
                    wideViewController.SHOW_TAB_BAR = false
                }
            }) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.offWhite)
                    .shadow(color: Color.white.opacity(0.4), radius: 10, x: -3, y: -3)
                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 8, y: 8)
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
                                .shadow(color: .black.opacity(0.5),
                                        radius: 2,
                                        x: 1, y: 1)
                                .shadow(color: .white.opacity(1),
                                        radius: 4,
                                        x: -1, y: -1)

                                Text(category.name)
                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.linearGradient(colors: [.Orange, .Orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .multilineTextAlignment(.center)
                                    .frame(width: (UIScreen.main.bounds.width - 30) / 2.5)
                                    .padding(.trailing, 5)
                                    .minimumScaleFactor(0.5)
                                    .shadow(radius: 4)
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 30, height: 150)
                    .matchedGeometryEffect(id: category.id, in: animation)
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.3))
            .padding(.bottom)
            .padding(.top)
        }
    }
}


struct fitnessView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
    }
}
