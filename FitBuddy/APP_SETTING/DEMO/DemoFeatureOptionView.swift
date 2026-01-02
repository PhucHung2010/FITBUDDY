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
        VStack {
            ForEach(DemoFeatures.allCases, id: \.self) {feature in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 1)) {
                        exercisePerformance.setController(to: feature)
                        exercisePerformance.perform()
                        performanceView = true
                    }
                }) {
                    HStack {
                        Image(systemName: feature.featureSystemImage(for: feature))
                        Text(feature.rawValue)
                    }
                    .font(.system(size: 25, weight: .heavy))
                    .foregroundColor(Color.Orange)
                    .shadow(radius: 3)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 40)
                    .background {
                        BlurView(style: theme.main.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    }
                }
                .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            }
        }
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground().ignoresSafeArea()
            AppSettingView()
                .environmentObject(UserController(user: UserModel(id: "no",
                                                                  name: "Hưng Nguyễn",
                                                                  email: "nhphung2468@gmail.com",
                                                                  imageURL: "https://lh3.googleusercontent.com/a/ACg8ocL1E5Imyb3wQUfxEZ8GIvyXOjgtU776TXxIxfk2U1b3AtK3h7I=s1000")))
                .environmentObject(AppThemeController())
                .environmentObject(TabViewController())
        }
    }
}
