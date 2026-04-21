//
//  TimePickerView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 24/06/2025.
//

import SwiftUI

struct TimePickerView: View {
    @EnvironmentObject var theme: AppThemeController
    
    var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var targetParameter: TargetExerciseParameterStorage?
    
    @State var showTimeSheet: Bool = false
    @State private var selectedMinute = 0
    @State private var selectedSecond = 0
    
    var body: some View {
        VStack() {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                    if exercisePerformance.targetTime == nil {
                        showTimeSheet.toggle()
                    } else {
                        exercisePerformance.targetTime = nil
                    }
                }
            }) {
                HStack {
                    Image(systemName: "clock.fill")
                    Text("Time")
                }
                .font(.system(size: 25, weight: .heavy))
                .foregroundColor((exercisePerformance.targetTime == nil) ? theme.main.accent : Color.lightOffWhite)
                .shadow(radius: 3)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background {
                    if !(exercisePerformance.targetTime == nil) {
                        theme.main.accent
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    } else {
                        BlurView(style: theme.main.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    }
                }
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if showTimeSheet {
                Group {
                    HStack(spacing: 0) {
                        Picker("", selection: $selectedMinute) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)")
                                    .font(.system(size: 25, weight: .heavy))
                                    .foregroundColor(theme.main.accent)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 55)
                        
                        Picker("", selection: $selectedSecond) {
                            ForEach(0..<60) { second in
                                Text("\(second)")
                                    .font(.system(size: 25, weight: .heavy))
                                    .foregroundColor(theme.main.accent)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 55)
                    }
                    .frame(height: 140)
                    
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                            showTimeSheet = false
                            exercisePerformance.targetTime = selectedMinute * 60 + selectedSecond
                        }
                        if exercisePerformance.targetTime == 0 {
                            exercisePerformance.targetTime = nil
                        }
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
                    .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                }
                .transition(.scale)
            }
            
            if exercisePerformance.targetTime != nil {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                        showTimeSheet = true
                        exercisePerformance.targetTime = nil
                    }
                }) {
                    Text("\(selectedMinute):\(selectedSecond)")
                        .font(.system(size: 25, weight: .heavy))
                        .foregroundColor(theme.main.accent)
                        .shadow(radius: 3)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background {
                            BlurView(style: theme.main.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .shadow(radius: 6)
                        }
                        .minimumScaleFactor(0.2)
                }
                .onAppear {
                    if let targetTime = exercisePerformance.targetTime {
                        selectedMinute = targetTime / 60
                        selectedSecond = targetTime % 60
                    }
                }
                .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                .transition(.scale)
            }
        }
        .mask(RoundedRectangle(cornerRadius: 20))
        .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2))
        // Set up targetParameter and save viewContext
        .onAppear {
            if !self.exercisePerformance.keepAvailable {
                self.targetParameter = TargetExerciseParameterStorage.loadTargetParameter(for: self.category?.name ?? "", in: viewContext)
                if Int(targetParameter?.targetTime ?? -1) == -1 {
                    self.exercisePerformance.targetTime = nil
                } else {
                    self.exercisePerformance.targetTime = Int(targetParameter?.targetTime ?? -1)
                }
            }
        }
        .onDisappear {
            targetParameter?.targetTime = Int32(exercisePerformance.targetTime ?? -1)
            try? viewContext.save()
        }
    }
}

struct TimePickerView_Previews: PreviewProvider {
    static var previews: some View {
        @State var category: Category?
        TimePickerView(category: category, exercisePerformance: FitnessExercisePerformance())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppThemeController())
    }
}
