//
//  RepPickerView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 23/06/2025.
//

import Foundation
import SwiftUI
import CoreData

struct RepPickerView: View {
    @EnvironmentObject var theme: AppThemeController
    var category: Category?
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var targetParameter: TargetExerciseParameterStorage?
    @State var showRepSheet: Bool = false
    
    init(category: Category?,
         exercisePerformance: FitnessExercisePerformance) {
        self.category = category
        self.exercisePerformance = exercisePerformance
    }
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
                    if exercisePerformance.targetCount == nil {
                        showRepSheet = true
                    } else {
                        exercisePerformance.targetCount = nil
                    }
                }
            }) {
                HStack {
                    Image(systemName: "repeat")
                    Text("Rep")
                }
                .font(.system(size: 25, weight: .heavy))
                .foregroundColor((exercisePerformance.targetCount == nil) ? theme.main.accent : Color.lightOffWhite)
                .shadow(radius: 3)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background {
                    if !(exercisePerformance.targetCount == nil) {
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
            .customHeightSheet(showSheet: $showRepSheet, sheetHeight: 400) {
                RepSettingView(input: $exercisePerformance.targetCount, showRepSheet: $showRepSheet)
                    .environmentObject(AppThemeController())
            } onEnd: {}

            
            if exercisePerformance.targetCount != nil {
                Button(action: {
                    showRepSheet = true
                }) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 20, weight: .bold))
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
                .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                .transition(.scale)
            }
        }
        .mask(RoundedRectangle(cornerRadius: 20))
        .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2))
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 1), value: exercisePerformance.targetCount)
        // Set up targetParameter and save viewContext
        .onAppear {
            if !self.exercisePerformance.keepAvailable {
                self.targetParameter = TargetExerciseParameterStorage.loadTargetParameter(for: self.category?.name ?? "", in: viewContext)
                if Int(targetParameter?.targetCount ?? -1) == -1 {
                    self.exercisePerformance.targetCount = nil
                } else {
                    self.exercisePerformance.targetCount = Int(targetParameter?.targetCount ?? -1)
                }
            }
        }
        .onDisappear {
            targetParameter?.targetCount = Int32(exercisePerformance.targetCount ?? -1)
            try? viewContext.save()
        }
    }
}



struct RepSettingView: View {
    @EnvironmentObject var theme: AppThemeController
    @Binding var input: Int?
    @Binding var showRepSheet: Bool
    @State private var showNumpad = false
    
    @AppStorage("availeblePicker") var availablePickerEncoded: String = ""
    
    var body: some View {
        ZStack {
            BlurView(style: theme.main.ultraThinMaterial).ignoresSafeArea()
            
            if !showNumpad {
                AvailablePicker(input: $input,
                                showNumpad: $showNumpad,
                                showRepSheet: $showRepSheet,
                                availablePickers: decodeAvailablePickerArray())
            } else {
                NumpadSheet(input: $input,
                            showRepSheet: $showRepSheet,
                            availablePicker: decodeAvailablePickerArray())
            }

        }
        .environmentObject(AppThemeController())
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 1), value: showNumpad)
        .frame(width: UIScreen.main.bounds.width - 40, height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 8, x: 10, y: 15)
        .shadow(radius: 8, x: -10, y: 15)
    }
    
    func decodeAvailablePickerArray() -> [Int] {
        @AppStorage("availablePicker") var availablePickerEncoded = ""
        return availablePickerEncoded
                .split(separator: ",")
                .compactMap { Int($0) }
    }
}


struct AvailablePicker: View {
    @Binding var input: Int?
    @Binding var showNumpad: Bool
    @Binding var showRepSheet: Bool
    @State var availablePickers: [Int]
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    @State private var isPressingOnText = false
    @State private var isPressingOnPlus = false
    @State private var beingPressedOn: Int? = nil

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                PickerButton(title: 0, systemImage: "plus")
                .scaleEffect(isPressingOnPlus ? 0.5 : 1.0)
                .onTapGesture {
                    showNumpad = true
                }
                
                ForEach(availablePickers, id: \.self) { availablePicker in
                    PickerButton(title: availablePicker)
                    .scaleEffect(isPressingOnText && beingPressedOn == availablePicker ? 0.5 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isPressingOnText)
                    .onTapGesture {
                        input = availablePicker
                        showRepSheet = false
                    }
                    .onLongPressGesture(minimumDuration: 1.5, pressing: { isPressing in
                        isPressingOnText = isPressing
                        if isPressing {beingPressedOn = availablePicker}
                        else {beingPressedOn = nil}
                    } ,perform: {
                        availablePickers.removeAll { $0 == availablePicker }
                        encodeAvailablePickerArray(availablePickers)
                        input = nil
                    })
                    
                }
            }
            .padding()
        }
    }
    
    func encodeAvailablePickerArray(_ array: [Int]) -> Void {
        @AppStorage("availablePicker") var availablePickerEncoded = ""
        let sortedArray = array.sorted()
        availablePickerEncoded = sortedArray.map { String($0) }.joined(separator: ",")
    }
}

struct NumpadSheet: View {
    @EnvironmentObject var theme: AppThemeController
    @Binding var input: Int?
    @State var numberString: String = ""
    @Binding var showRepSheet: Bool
    @State var availablePicker: [Int]
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                BlurView(style: theme.main.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 7)
                Text(numberString)
                    .font(.system(size: 40, weight: .black, design: .default))
                    .foregroundColor(.Orange)
                    .shadow(radius: 2)
            }
            .frame(width: UIScreen.main.bounds.width - 60, height: 80)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(numbers, id: \.self) { number in
                    NumpadButton(title: number) {
                        numberString.append(number)
                    }
                }

                NumpadButton(title: "←") {
                    if !(numberString.isEmpty) {
                        numberString.removeLast()
                    }
                }

                NumpadButton(title: "0") {
                    numberString.append("0")
                }

                NumpadButton(title: "checkmark", systemImage: "checkmark") {
                    showRepSheet = false
                    if let validInput = input {
                        if !availablePicker.contains(validInput) {
                            availablePicker.append(validInput)
                            encodeAvailablePickerArray(availablePicker)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .onChange(of: numberString) { newValue in
            if newValue.count > 4 || newValue.first == "0" {
                input = nil
                numberString = ""
            }
            else {
                input = Int(newValue) ?? nil
            }
        }
        .padding()
        .transition(.scale.combined(with: .offset(x: 200)))
    }
    
    
    func encodeAvailablePickerArray(_ array: [Int]) -> Void {
        @AppStorage("availablePicker") var availablePickerEncoded = ""
        let sortedArray = array.sorted()
        availablePickerEncoded = sortedArray.map { String($0) }.joined(separator: ",")
    }
}

struct RepPickerView_Previews: PreviewProvider {
    static var previews: some View {
        @State var category: Category?
        RepPickerView(category: category, exercisePerformance: FitnessExercisePerformance())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AppThemeController())
    }
}
