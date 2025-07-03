//
//  RepPickerView.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 23/06/2025.
//

import Foundation
import SwiftUI

struct RepPickerView: View {
    @ObservedObject var exercisePerformance: FitnessExercisePerformance
    @State var showRepSheet: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    if exercisePerformance.targetCount == nil {
                        showRepSheet = true
                    } else {
                        exercisePerformance.targetCount = nil
                    }
                }
            }) {
                Text("REP")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor((exercisePerformance.targetCount == nil) ? Color.Orange : Color.lightOffWhite)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 50)
                    .background {
                        if !(exercisePerformance.targetCount == nil) {
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
            .customHeightSheet(showSheet: $showRepSheet, sheetHeight: 400) {
                RepSettingView(input: $exercisePerformance.targetCount, showRepSheet: $showRepSheet)
            } onEnd: {}
            
            if let targetCount = exercisePerformance.targetCount {
                Button(action: {
                    showRepSheet = true
                }) {
                    Text("\(targetCount)")
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
                .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
                .transition(.offset(y: -30).combined(with: .scale.combined(with: .opacity)))
            }
        }
        .padding(5)
        .background {
            BlurView(style: .systemMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.6), value: exercisePerformance.targetCount)
    }
}

struct RepSettingView: View {
    @Binding var input: Int?
    @Binding var showRepSheet: Bool
    @State private var showNumpad = false
    
    @AppStorage("availeblePicker") var availablePickerEncoded: String = ""
    
    var body: some View {
        ZStack {
            BlurView(style: .systemUltraThinMaterialLight).ignoresSafeArea()
            
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
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.7), value: showNumpad)
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
                .onLongPressGesture(minimumDuration: 2, pressing: {isPressing in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        isPressingOnPlus = isPressing
                    }
                }, perform: {})
                
                ForEach(availablePickers, id: \.self) { availablePicker in
                    PickerButton(title: availablePicker)
                    .scaleEffect(isPressingOnText && beingPressedOn == availablePicker ? 0.5 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isPressingOnText)
                    .onTapGesture {
                        input = availablePicker
                        showRepSheet = false
                    }
                    .onLongPressGesture(minimumDuration: 2, pressing: { isPressing in
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
                BlurView(style: .systemUltraThinMaterialLight)
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
                        availablePicker.append(validInput)
                        encodeAvailablePickerArray(availablePicker)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .onChange(of: numberString) { newValue in
            if newValue.count > 6 || newValue.first == "0" {
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
        RepPickerView(exercisePerformance: FitnessExercisePerformance())
    }
}
