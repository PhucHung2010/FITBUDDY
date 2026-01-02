//
//  PreviewImage.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 25/06/2025.
//

import SwiftUI

struct PreviewImage: View {
    @EnvironmentObject var theme: AppThemeController
    @Namespace var animation1
    @Namespace var animation2

    @State private var useFirstAnimation = true

    private var currentNamespace: Namespace.ID {
        useFirstAnimation ? animation1 : animation2
    }
    
    let category: Category
    @State private var selectedImage: (String, String)?
    var body: some View {
        ZStack {
            TabView {
                ForEach(category.images, id: \.0) {image in
                    HStack(spacing: 5) {
                        Button(action: {
                            useFirstAnimation = true
                            withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                selectedImage = (image.0, image.1)
                            }
                        }) {
                            Image(image.0)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: image.0, in: animation1)
                        }
                        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))

                        
                        Button(action: {
                            useFirstAnimation = false
                            withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                                selectedImage = (image.1, image.0)
                            }
                        }) {
                            Image(image.1)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: image.1, in: animation2)
                        }
                        .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .frame(width: UIScreen.main.bounds.width - 30,
                   height: (UIScreen.main.bounds.width - 35) * 3 / 4)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .background(BlurRoundedBackground(cornerRadius: 25, style: .systemMaterialLight))
            .transition(.scale)
            
            if let image = selectedImage {
                TabView {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedImage = nil
                        }
                    }) {
                        Image(image.0)
                            .resizable()
                            .scaledToFit()
                            .tag(0)
                    }
                    .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedImage = nil
                        }
                    }) {
                        Image(image.1)
                            .resizable()
                            .scaledToFit()
                            .tag(1)
                    }
                    .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                }
                .tabViewStyle(.page)
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .frame(width: UIScreen.main.bounds.width - 30, height: (UIScreen.main.bounds.width - 30) * 3 / 2)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .transition(.scale.combined(with: .opacity))
                .matchedGeometryEffect(id: image.0, in: currentNamespace)
            }
        }
    }
}

struct PreviewImage_Previews: PreviewProvider {
//    static var previews: some View {
//        if let category = FitnessExerciseCategory().categories.first {
//            PreviewImage(category: category)
//                .environmentObject(AppThemeController())
//        }
//    }
    static var previews: some View {
        @State var category = FitnessExerciseCategory().categories.first
        ExerciseParameterSettingView(category: $category,
                                     exercisePerformance: FitnessExercisePerformance())
            .environmentObject(TabViewController())
            .environmentObject(AppThemeController())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
