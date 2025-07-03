//
//  StatusBar.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 17/06/2025.
//

import SwiftUI

struct StatusBarView: View {
    @ObservedObject var controller: FitnessExercisePerformance

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            ZStack {
                VStack {
                    if isLandscape {
                        HStack(spacing: 20) {
                            counterSection(screenWidth: geometry.size.width)
                            if controller.feedback {
                                feedbackScrollSection(screenWidth: geometry.size.width)
                            }
                        }
                    } else {
                        VStack(spacing: 0) {
                            counterSection(screenWidth: geometry.size.width)
                            if controller.feedback {
                                feedbackScrollSection(screenWidth: geometry.size.width)
                            }
                        }
                    }
                }
                .padding(.horizontal, 7)
                .background(
                    BlurView(style: .systemUltraThinMaterialLight)
                        .clipShape(RoundedRectangle(cornerRadius: 27))
                        .ignoresSafeArea(edges: .horizontal)
                )
                .frame(width: geometry.size.width - 30)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    func counterSection(screenWidth: Double) -> some View {
        HStack() {
            if let targetCount = controller.targetCount {
                Text("\(controller.totalCorrect) | \(targetCount)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
                    .shadow(color: .white.opacity(0.6), radius: 1, x: -1.5, y: -1.5)
                    .frame(width: 100, height: 45)
                    .padding(.horizontal, 1)
                    .background(
                        BlurView(style: .systemUltraThinMaterialLight)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    )
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
            }


            if let targetTime = controller.targetTime {
                Text("\(controller.totalTime) | \(targetTime)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
                    .shadow(color: .white.opacity(0.6), radius: 1, x: -1.5, y: -1.5)
                    .frame(width: 100, height: 45)
                    .padding(.horizontal, 1)
                    .background(
                        BlurView(style: .systemUltraThinMaterialLight)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 6)
                    )
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
            }


            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    controller.exerciseEnded = true
                    controller.quickPose.stop()
                }
            }) {}
                .buttonStyle(ScaledButtonStyle_OffColorText(text: "Finish", originColor: .green.opacity(0.8), offColor: .offWhite, textFont: 30, scaleRadius: 0.7, animationDuration: 0.2))
        }
        .padding(.top, 5)
        .padding(.bottom, 5)
    }

    @ViewBuilder
    func feedbackScrollSection(screenWidth: Double) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                if let feedbacks = controller.feedbackText {
                    ForEach(feedbacks.indices, id: \.self) { index in
                        Text(feedbacks[index])
                            .font(.system(size: 35, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 2, y: 2)
                            .shadow(color: .white.opacity(0.5), radius: 1, x: -1, y: -1)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.3)
                            .id(index)
                            .frame(height: 50)
                            .padding(.horizontal, 2)
                    }
                }
            }
            .onChange(of: controller.feedbackText) { _ in
                withAnimation {
                    proxy.scrollTo((controller.feedbackText?.count ?? 1) - 1, anchor: .bottom)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(height: 50)
    }
}

//struct StatusBar_Previews: PreviewProvider {
//    static var previews: some View {
//        StatusBar()
//    }
//}
