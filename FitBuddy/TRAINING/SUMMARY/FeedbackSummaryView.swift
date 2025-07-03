//
//  FeedbackSummary.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 30/06/2025.
//

import SwiftUI

struct FeedbackSummaryView: View {
    let screenWidth: CGFloat
    let feedbackText: [String]?
    var totalCorrect: Int
    var totalCount: Int
    let accuracy: Int
    @State private var showFeedback: Bool = true
    
    init(screenWidth: CGFloat,
         feedbackText: [String]?,
         totalCorrect: Int,
         totalCount: Int) {
        self.screenWidth = screenWidth
        self.feedbackText = feedbackText
        self.totalCorrect = totalCorrect
        self.totalCount = totalCount
        self.accuracy = totalCount != 0 ? Int((totalCorrect / totalCount) * 100) : 0
    }
    var body: some View {
        VStack {
            Button(action: {
                if feedbackText != nil {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showFeedback.toggle()
                    }
                }
            }) {
                VStack {
                    Text("Accuracy - \(accuracy)%")
                    if showFeedback && feedbackText != nil {Text("Feedback")}
                }
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(showFeedback ? .lightOffWhite : .cyan)
                .padding(3)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: screenWidth)
                        .foregroundColor(showFeedback ? .cyan : .lightOffWhite)
                )
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if showFeedback {
                if let feedbackText = feedbackText {
                    ScrollView {
                        VStack(spacing: 5) {
                            ForEach(feedbackText, id: \.self) {feedback in
                                Text(feedback)
                                    .foregroundColor(.black)
                                    .font(.system(size: 25, weight: .regular))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Divider().background(Color.darkGray)
                            }
                            .padding(.horizontal)
                            .padding(.top, 3)
                        }
                    }
                    .frame(width: screenWidth)
                    .background(
                        BlurView(style: .systemUltraThinMaterialLight)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .transition(.offset(y: -200).combined(with: .scale).combined(with: .opacity))
                }
            }
        }
        .frame(width: screenWidth)
        .padding(5)
        .background(
            BlurView(style: .systemUltraThinMaterialLight)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(radius: 2)
        )
    }
}

struct FeedbackSummary_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackSummaryView(screenWidth: UIScreen.main.bounds.width - 40,
                        feedbackText: ["ahihi"],
                        totalCorrect: 10,
                        totalCount: 20)
    }
}
