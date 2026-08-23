//
//  DemoView.swift
//  FitBuddy
//
//  Created by Nguyen Huu Phuc Hung on 4/8/25.
//
import SwiftUI

struct DemoFeatureOptionView: View {
    @EnvironmentObject var theme: AppThemeController
    
    @Binding var performanceView: Bool
    
    @ObservedObject var exercisePerformance: DemoFeaturesPerformance
    var body: some View {
        VStack(spacing: 12) {
            ForEach(DemoFeatures.allCases, id: \.self) { feature in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                        exercisePerformance.setController(to: feature)
                        exercisePerformance.perform()
                        performanceView = true
                    }
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: feature.featureSystemImage(for: feature))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(theme.main.text)
                            .frame(width: 36, height: 36)
                            .neumorphicCircle()
                        
                        Text(feature.rawValue)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(theme.main.text)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(theme.main.text.opacity(0.3))
                    }
                    .padding(.horizontal, 16)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 56)
                    .neumorphicCard(cornerRadius: 22)
                }
                .buttonStyle(NeumorphicStretchButtonStyle(scaleRadius: 0.96))
            }
        }
        .padding(.vertical, 4)
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            AppSettingView()
                .environmentObject(UserController())
                .environmentObject(AppThemeController())
                .environmentObject(TabViewController())
        }
    }
}
