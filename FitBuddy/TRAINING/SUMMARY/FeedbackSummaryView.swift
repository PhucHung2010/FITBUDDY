//
//  FeedbackSummary.swift
//  FitBuddy
//
//  Created by Hung Nguyen on 30/06/2025.
//

import SwiftUI

struct FeedbackSummaryView: View {
    @EnvironmentObject var theme: AppThemeController
    let screenWidth: CGFloat
    @State var feedbackText: [String]?
    var totalCorrect: Int
    var totalCount: Int
    let accuracy: Int
    
    var convertByJSONString: String?
    @State private var showFeedback: Bool = true
    
    init(screenWidth: CGFloat,
         feedbackText: [String]?,
         totalCorrect: Int,
         totalCount: Int,
         convertByJSONString: String? = nil) {
        self.screenWidth = screenWidth
        _feedbackText =  State(initialValue: feedbackText)
        self.totalCorrect = totalCorrect
        self.totalCount = totalCount
//        self.accuracy = totalCount != 0 ? Int((totalCorrect / totalCount) * 100) : 0
        self.accuracy = totalCount != 0 ? Int(Double(totalCorrect) / Double(totalCount) * 100.0) : 0
        self.convertByJSONString = convertByJSONString
    }
    
    var body: some View {
        VStack {
            Button(action: {
                if feedbackText != nil {
                    withAnimation(.spring(response: 0.5, dampingFraction: 1)) {
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
                        .foregroundColor(showFeedback ? .cyan : theme.main.mainColor)
                )
            }
            .buttonStyle(ScaledButtonStyle(scaleRadius: 0.7, animationDuration: 0.2))
            
            if showFeedback {
                if let feedbackText = feedbackText {
                    ScrollView {
                        VStack(spacing: 5) {
                            ForEach(feedbackText, id: \.self) {feedback in
                                if feedback != "" {
                                    Text(feedback)
                                        .foregroundColor(theme.main.text)
                                        .font(.system(size: 25, weight: .regular))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Divider().background(Color.darkGray)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 3)
                        }
                    }
                    .frame(width: screenWidth)
                    .background(
                        BlurRoundedBackground()
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .transition(.offset(y: -200).combined(with: .scale).combined(with: .opacity))
                }
            }
        }
        .frame(width: screenWidth)
        .mask(RoundedRectangle(cornerRadius: 20))
        .background (BlurRoundedBackground(cornerRadius: 20, shadowRadius: 2, style: .systemUltraThinMaterialLight))
        .onAppear {
            if let JSONString = convertByJSONString {
                feedbackText = SummaryExerciseParameterStorage.decodeFeedbackStrings(JSONString)
                if feedbackText == [""] {
                    feedbackText = ["Please turn on feedback!"]
                }
            }
        }
    }
}

struct FeedbackSummary_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackSummaryView(screenWidth: UIScreen.main.bounds.width - 40,
                        feedbackText: nil,
                        totalCorrect: 10,
                        totalCount: 20)
        .environmentObject(AppThemeController())
    }
}
