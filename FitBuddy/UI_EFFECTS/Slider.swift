//
//  Slider.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 23/06/2025.
//

import SwiftUI

struct CustomSlider: View {
    
    @Binding private var sliderValue: Float
    @State private var draftSliderValue: Float
    @State private var isDragging = false
    @State private var boardOffset: CGFloat = 0
    
    @State private var sliderLimit: CGFloat
    
    let sliderWidth: CGFloat
    let action: () -> Void
    
    init(_ sliderValue: Binding<Float>,_ sliderLimit: CGFloat = 100, sliderWidth: CGFloat = 300, onEditingChanged: @escaping () -> Void = {}) {
        self._sliderValue = sliderValue
        _sliderLimit = State(initialValue: sliderLimit)
        self.sliderWidth = sliderWidth
        self.action = onEditingChanged
        self.draftSliderValue = sliderValue.wrappedValue
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.gray.opacity(0.3))
                .shadow(radius: 1)
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.lightGray, lineWidth: 3))
                .frame(width: (sliderWidth), height: 25)
                .overlay() {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.Orange)
                        .frame(width: CGFloat(CGFloat(draftSliderValue) / sliderLimit) * (sliderWidth), height: 25)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    RoundedRectangle(cornerRadius: 45)
                        .fill(Color.white)
                        .frame(width: 20, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 45)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
                        .offset(x: CGFloat(CGFloat(draftSliderValue) / sliderLimit) * (sliderWidth))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    isDragging = true
//                                        withAnimation(.spring(response: 0.3, dampingFraction: 1)) {
                                    draftSliderValue = Float(min(max(0, Double(gesture.location.x / (sliderWidth) * sliderLimit) - 10), sliderLimit))
//                                        }
                                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 1, blendDuration: 0.1)) {
                                        boardOffset = CGFloat(CGFloat(draftSliderValue) / sliderLimit) * (sliderWidth)
                                    }
                                    action()
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    sliderValue = draftSliderValue
                                }
                        )
                        .offset(x: -10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                     
                    if isDragging {
                        Text("\(Int(draftSliderValue))")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.darkGray.opacity(0.9))
                            .cornerRadius(30)
                            .offset(x: boardOffset - 10, y: -45)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
        }
        .animation(.easeInOut(duration: 0.3), value: isDragging)
        .onChange(of: sliderValue) { newValue in
            draftSliderValue = newValue
        }
    }
}

struct TestSlider: View {
    @State private var sliderColor: Color = .orange
    @State private var currentFontSize: Float = 20
    var body: some View {
        ZStack {
            CustomSlider($currentFontSize)
        }
        
    }
}

struct Slider_Previews: PreviewProvider {
    static var previews: some View {
        TestSlider()
    }
}
