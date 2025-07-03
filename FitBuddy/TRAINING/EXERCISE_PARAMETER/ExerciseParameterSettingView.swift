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
    @Binding var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    @EnvironmentObject var wideViewController: WideViewController
    @State var showInstruction: Bool = false
    @State var showAdjustment: Bool = false
    @State var showImage: Bool = true
    
    
    init(category: Binding<Category?>,
         exercisePerformance: FitnessExercisePerformance) {
        self._category = category
        self.exercisePerformance = exercisePerformance
    }

    var body: some View {
        if !exercisePerformance.exerciseStarted && !exercisePerformance.exerciseEnded {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Button(action: {
                            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7)) {
                                category = nil
                                wideViewController.SHOW_TAB_BAR = true
                            }
                
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundColor(.Orange)
                                Text("Library")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundColor(.Orange)
                            }
                            .padding(2)
                            .background (
                                BlurView(style: .systemMaterialLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                            )
                            .shadow(radius: 2)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        
                        
                        if let category = category {
                            VStack(spacing: 10) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        showImage.toggle()
                                    }
                                }) {
                                    Text(category.name)
                                        .font(.system(size: 30, weight: .black))
                                        .foregroundColor(Color.Orange)
                                        .shadow(radius: 3)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                        .background {
                                            BlurView(style: .systemMaterialLight)
                                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                                .shadow(radius: 4)
                                        }
                                }
                                .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                                
                                if showImage {
                                    PreviewImage(category: category)
                                        .padding(5)
                                        .background(
                                            BlurView(style: .systemMaterialLight)
                                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                        )
                                        .transition(.offset(y: -300).combined(with: .scale.combined(with: .opacity)))
                                }
                            }
                            .padding(5)
                            .background(
                                BlurView(style: .systemUltraThinMaterialLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                            )
                            
                        }
                        
                        VStack {
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    showInstruction.toggle()
                                }
                            }) {
                                Text("INSTRUCTION")
                                    .font(.system(size: 30, weight: .black))
                                    .foregroundColor(showInstruction ? .lightOffWhite : Color.Orange)
                                    .shadow(radius: 3)
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                                    .background {
                                        if (showInstruction) {
                                            Color.Orange
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                                .shadow(radius: 6)
                                        } else {
                                            Color.lightOffWhite
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                                .shadow(radius: 6)
                                        }
                                    }
                            }
                            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                            
                            if showInstruction {
                                if let category = category {
                                    InstructionView(category: category)
                                }
                            }
                        }
                        .padding(5)
                        .background(
                            BlurView(style: .systemUltraThinMaterialLight)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 2)
                        )
                        
                        VStack {
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    showAdjustment.toggle()
                                    if let adjustment = category?.exerciseAdjustment {
                                        exercisePerformance.controller = adjustment
                                        print("Adjusted")
                                    }
                                }
                            }) {
                                Text("ADJUSTMENT")
                                    .font(.system(size: 30, weight: .black))
                                    .foregroundColor(showAdjustment ? .lightOffWhite : Color.Orange)
                                    .shadow(radius: 3)
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                                    .background {
                                        if showAdjustment {
                                            Color.Orange
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                                .shadow(radius: 6)
                                        } else {
                                            Color.lightOffWhite
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                                .shadow(radius: 6)
                                        }
                                    }
                            }
                            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                            
                            if showAdjustment {
                                AdjustmentView(exercisePerformance: exercisePerformance)
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        exercisePerformance.exerciseStarted = true
                                    }
                                }) {
                                    Text("START")
                                        .font(.system(size: 30, weight: .black))
                                        .foregroundColor(.lightOffWhite)
                                        .shadow(radius: 3)
                                        .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                                        .background {
                                            Color.green.opacity(0.9)
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                                .shadow(radius: 6)
                                        }
                                }
                                .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                                .transition(.offset(y: -300).combined(with: .scale.combined(with: .opacity)))
                            }
                        }
                        .padding(5)
                        .background(
                            BlurView(style: .systemUltraThinMaterialLight)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 2)
                        )
                        
                        Spacer().frame(height: 100)
                    }
                }   
            }
        }
    }
}

struct exerciseParameterSettingView: View {
    @State var category = ExerciseCategory().categories.first
    var body: some View {
        ExerciseParameterSettingView(category: $category,
                                     exercisePerformance: FitnessExercisePerformance())
    }
}



struct TrainingView_CustomePreviews_Previews: PreviewProvider {
    static var previews: some View {
        exerciseParameterSettingView()
    }
}
