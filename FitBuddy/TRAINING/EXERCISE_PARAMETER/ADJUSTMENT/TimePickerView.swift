//
//  TimePickerView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 24/06/2025.
//

import SwiftUI

struct TimePickerView: View {
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    @State var showTimeSheet: Bool = false
    
    @State private var selectedMinute = 0
    @State private var selectedSecond = 0
    
    var body: some View {
        VStack() {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    if exercisePerformance.targetTime == nil {
                        showTimeSheet.toggle()
                    } else {
                        exercisePerformance.targetTime = nil
                    }
                }
            }) {
                Text("TIME")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor((exercisePerformance.targetTime == nil) ? Color.Orange : Color.lightOffWhite)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                    .background {
                        if !(exercisePerformance.targetTime == nil) {
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
            
            if showTimeSheet {
                Group {
                    HStack(spacing: 0) {
                        Picker("", selection: $selectedMinute) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)")
                                    .font(.system(size: 25, weight: .heavy))
                                    .foregroundColor(.Orange)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 55)
                        
                        Picker("", selection: $selectedSecond) {
                            ForEach(0..<60) { second in
                                Text("\(second)")
                                    .font(.system(size: 25, weight: .heavy))
                                    .foregroundColor(.Orange)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 55)
                    }
                    
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showTimeSheet = false
                            exercisePerformance.targetTime = selectedMinute * 60 + selectedSecond
                        }
                        if exercisePerformance.targetTime == 0 {
                            exercisePerformance.targetTime = nil
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(Color.lightOffWhite)
                            .shadow(radius: 3)
                            .frame(width: 110, height: 50)
                            .background {
                                Color.Orange
                                    .clipShape(RoundedRectangle(cornerRadius: 40))
                                    .shadow(radius: 6)
                            }
                    }
                    .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                }
                .transition(.offset(y: -100).combined(with: .scale.combined(with: .opacity)))
            }
            
            if exercisePerformance.targetTime != nil {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showTimeSheet = true
                        exercisePerformance.targetTime = nil
                    }
                }) {
                    Text("\(selectedMinute):\(selectedSecond)")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundColor(Color.Orange)
                        .shadow(radius: 3)
                        .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                        .background {
                            BlurView(style: .systemUltraThinMaterialLight)
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
                .transition(.offset(y: -30).combined(with: .scale.combined(with: .opacity)))
            }
        }
        .padding(5)
        .background {
            BlurView(style: .systemMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }

}

struct TimePickerView_Previews: PreviewProvider {
    static var previews: some View {
        TimePickerView(exercisePerformance: FitnessExercisePerformance())
    }
}
