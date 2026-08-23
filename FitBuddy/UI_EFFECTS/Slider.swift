//
//  Slider.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 23/06/2025.
//

import SwiftUI

struct CustomSlider: View {
    @EnvironmentObject var theme: AppThemeController
    @Binding private var sliderValue: Float
    @State private var draftSliderValue: Float
    @State private var isDragging = false
    @State private var boardOffset: CGFloat = 0
    
    @State private var sliderLimit: CGFloat
    let sliderWidth: CGFloat
    let action: () -> Void
    
    init(_ sliderValue: Binding<Float>, _ sliderLimit: CGFloat = 100, sliderWidth: CGFloat = 300, onEditingChanged: @escaping () -> Void = {}) {
        self._sliderValue = sliderValue
        _sliderLimit = State(initialValue: sliderLimit)
        self.sliderWidth = sliderWidth
        self.action = onEditingChanged
        self.draftSliderValue = sliderValue.wrappedValue
    }
    
    var body: some View {
        let isLight = theme.appTheme == .light
        let progressWidth = max(0, min(sliderWidth, CGFloat(CGFloat(draftSliderValue) / sliderLimit) * sliderWidth))
        
        ZStack(alignment: .leading) {
            // Sunken Groove Track
            Capsule()
                .fill(isLight ? NeumorphicColors.lightInset : NeumorphicColors.darkInset)
                .frame(width: sliderWidth, height: 16)
                .neumorphicInset(cornerRadius: 8)
                .overlay(
                    // Filled Progress Track
                    HStack {
                        Capsule()
                            .fill(theme.accentGradient)
                            .frame(width: progressWidth, height: 12)
                            .padding(.leading, 2)
                        Spacer(minLength: 0)
                    }
                )
            
            // Raised Circular Thumb Knob with Center Colored Dot
            Circle()
                .fill(isLight ? NeumorphicColors.lightSurface : NeumorphicColors.darkSurface)
                .frame(width: 28, height: 28)
                .neumorphicCircle(shadowRadius: 5, shadowDistance: 3)
                .overlay(
                    Circle()
                        .fill(theme.accentGradient)
                        .frame(width: 10, height: 10)
                )
                .offset(x: max(0, min(sliderWidth - 28, progressWidth - 14)))
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            isDragging = true
                            let clampedX = max(0, min(Double(gesture.location.x / sliderWidth * sliderLimit), Double(sliderLimit)))
                            draftSliderValue = Float(clampedX)
                            boardOffset = CGFloat(CGFloat(draftSliderValue) / sliderLimit) * sliderWidth
                            action()
                        }
                        .onEnded { _ in
                            isDragging = false
                            sliderValue = draftSliderValue
                        }
                )
            
            // Floating Value Badge
            if isDragging {
                Text("\(Int(draftSliderValue))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(theme.accentGradient)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
                    )
                    .offset(x: max(0, min(sliderWidth - 40, progressWidth - 20)), y: -38)
            }
        }
        .frame(width: sliderWidth, height: 36)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
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
